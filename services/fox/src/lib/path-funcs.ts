export const getImageUrl = (docId: string, imageName: string) => {
    if (import.meta.env.NODE_ENV === "production") {
        // generates url to mona server in production. the url consists of only path.
        // the host:port part is resolved by reverse proxy server.
        return `/documents/${docId}/images/${imageName}`;
    } else if (import.meta.env.NODE_ENV === "development") {
        // in development, generates url to local API.
        return `http://localhost:4321/api/${docId}/images/${imageName}`;
    } else {
        throw new Error("Unknown environment");
    }
};

