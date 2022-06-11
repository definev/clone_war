import "./global-features/quick-search.js";

// Pagination is only relevant on `/p` pages or home page
if (location.pathname === "/" || location.pathname.includes("/p/")) {
  import("./global-features/pagination.js");
}

// Related icons are only relevant on individual icon views
if (location.pathname.includes("/icons/")) {
  import("./global-features/related-icons.js");
}

// Add js class to every page that supports JS
document.body.classList.add("js");
