"use client";

import React from "react"
import Link from "next/link";
import { usePathname } from "next/navigation";

const Header: React.FC = () => {
    const pathname = usePathname();

    return (
        <header className="sticky top-0 z-50 w-full shadow-md bg-gray-100 text-black">
            <nav className="container mx-auto px-6 py-3">
                <div className="flex items-center justify-between gap-6">
                    <div>
                        <div className="header-logo">
                            {pathname === "/" ? (
                                <h1>Home</h1>
                            ) : (
                                <h1>
                                    <Link className="hover:underline hover:text-blue-600" href="/">Home</Link>
                                </h1>
                            )}
                        </div>
                    </div>
                    <div className="flex items-center gap-4">
                        <div className="header-search">
                            {pathname === "/search" ? (
                                <h1 className="border-b-2">簡易検索</h1>
                            ) : (
                                <h1>
                                    <Link className="hover:underline hover:text-blue-600" href="/search">簡易検索</Link>
                                </h1>
                            )}
                        </div>
                        <div className="header-doclist">
                            {pathname === "/docList" ? (
                                <h1 className="border-b-2">書誌検索</h1>
                            ) : (
                                <h1>
                                    <Link className="hover:underline hover:text-blue-600" href="/docList">書誌検索</Link>
                                </h1>
                            )}
                        </div>
                        <div className="header-metadata-editor">
                            {pathname === "/metadata" ? (
                                <h1 className="border-b-2">メタデータ編集</h1>
                            ) : (
                                <h1>
                                    <Link className="hover:underline hover:text-blue-600" href="/metadata">メタデータ編集</Link>
                                </h1>
                            )}
                        </div>
                    </div>
                </div>
            </nav>
        </header >
    );
}

export default Header;