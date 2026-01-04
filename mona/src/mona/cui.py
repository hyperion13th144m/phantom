import os
import argparse
import tempfile
from typing import List
from pathlib import Path
from typing import Iterator
from multiprocessing import Process, Queue
from sparrow import ArchiveInfo, ArchiveCode, extract, InvalidArchive
from gibbon.uploader.funcs import get_args, init_uploaders
from gibbon.uploader.base import Uploader

PROCESSES = 4


def main():
    args = get_arguments()
    queue = Queue()
    processes = []

    # create and initialize processes
    for _ in range(args.processes):
        p = Process(target=process, args=(args, queue))
        p.start()
        processes.append(p)

    try:
        # give archive to each processes via queue
        for item in find_archives(args.src_dir):
            queue.put(item)

        # give None for quit processes
        for _ in range(args.processes):
            queue.put(None)

    except KeyboardInterrupt:
        print("Main process interrupted")
        for p in processes:
            p.terminate()
    finally:
        # wait for all processes
        for p in processes:
            p.join()


def process(args, queue):
    # sub process main
    uploaders = init_uploaders(args)
    filters = get_filters(args.filters)
    force = args.force

    while True:
        item = queue.get()
        if item is None:
            break

        try:
            archive = ArchiveInfo(Path(item))
            if filters and archive.code in filters:
                # process archive if it matches filters 
                process2(archive, uploaders, force)
            elif filters is None:
                process2(archive, uploaders, force)
        except InvalidArchive as e:
            # ignore not Archive files
            pass
        except FileNotFoundError as e:
            # no xml corresponding to archive.
            print('[ERROR] {}, {}'.format(item, e))
        except KeyboardInterrupt:
            print("Worker interrupted")
        except Exception as e:
            print('[ERROR] {}, {}'.format(item, e))


def process2(archive: ArchiveInfo, uploaders: List[Uploader], force=False):
    # if force is true, forcefully upload regardless of whether the archive 
    # identified by the id already exists.
    if force is False:
        # check if id exists on all uploaders
        if all([u.exists(archive.id) for u in uploaders]):
            print('[SKIP] {}'.format(archive.archive))
            return

    with tempfile.TemporaryDirectory() as _d:
        d = Path(_d)
        try:
            extract(archive, d)
        except Exception as e:
            print('[ERROR] archive cannot be extracted. {}'.format(archive.archive))
            import traceback
            traceback.print_exc()
            return

        num_uploaders = len(uploaders)
        success: List[Uploader] = []
        for uploader in uploaders:
            try:
                uploader.upload(archive.id, d)
                success.append(uploader)
            except Exception as e:
                print('[ERROR][{}] {}, {}'.format(uploader.name(), archive.archive, e))
                break

        if len(success) != num_uploaders:
            # not all uploaders finished in success, then rollback.
            print('[ROLLBACK] {}'.format(archive.archive))
            for u in success:
                u.rollback(archive.id)
        else:
            print('[UPLOADED] {}'.format(archive.archive))

def get_arguments():
    parser = argparse.ArgumentParser(
        prog='gibbon', description='a utility program for uploading data to Groonga server')
    parser.add_argument(
        'src_dir', help='path to the directory where the archives are stored in')
    parser.add_argument(
        '--filters', help='filter for upload archives', default='all')
    parser.add_argument(
        '--force', help='force to upload', action='store_true')
    parser.add_argument(
        '--processes', help='number of processes for processing data', default=PROCESSES)
    get_args(parser)
    return parser.parse_args()


def find_archives(directory: str) -> Iterator[str]:
    for root, _, files in os.walk(directory):
        for file in files:
            yield os.path.join(root, file)


def get_filters(filter_str: str):
    if filter_str == 'all':
        return None

    filters = []
    for f in filter_str.split(','):
        try:
            filters.append(ArchiveCode(f))
        except:
            pass
    return filters


if __name__ == '__main__':
    main()
