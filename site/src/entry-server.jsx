import React from "react";
import { renderToString } from "react-dom/server";
import { App } from "./App.jsx";
import { pageContent } from "./page-content.js";

export const getPageCatalog = () => Object.values(pageContent).map(({ html, ...page }) => page);
export const render = (path) => renderToString(<App path={path} />);
