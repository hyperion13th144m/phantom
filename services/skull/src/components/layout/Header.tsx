import Link from "next/link";

const navItems = [
    { label: "メタデータ編集", href: "/search" },
    { label: "再同期/レストア", href: "/sync-status" },
    { label: "バックアップ", href: "/db" },
];

export default function Header() {
    return (
        <header className="border-b">
            <div className="mx-auto flex max-w-7xl items-center gap-6 px-6 py-3 bg-primary dark:bg-background dark:text-white">
                <Link
                    href="/"
                    className="text-sm font-bold tracking-tight"
                >
                    Home
                </Link>
                <nav className="flex gap-1">
                    {navItems.map((item) => (
                        <Link
                            key={item.href}
                            href={item.href}
                            className="rounded-md px-3 py-2 text-sm text-black dark:text-white hover:bg-gray-100 hover:text-gray-900"
                        >
                            {item.label}
                        </Link>
                    ))}
                </nav>
            </div>
        </header>
    );
}
