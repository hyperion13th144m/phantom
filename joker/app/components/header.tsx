import React from "react"

const Header: React.FC = () => {
    return (
        <header className="sticky top-0 z-50 w-full shadow-md bg-gray-100 text-black">
            <nav className="container mx-auto px-6 py-3">
                <div className="flex items-center justify-between">
                    <div className="header-logo">Phantom</div>
                    <div className="header-menu">
                        <div>簡易検索</div>
                    </div>
                </div>
            </nav>
        </header>
    );
}

export default Header;