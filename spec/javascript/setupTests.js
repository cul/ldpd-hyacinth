import { JSDOM } from 'jsdom';
import fetch from 'jest-fetch-mock';

// jest-dom adds custom jest matchers for asserting on DOM nodes.
// allows you to do things like:
// expect(element).toHaveTextContent(/react/i)
// learn more: https://github.com/testing-library/jest-dom
import '@testing-library/jest-dom/extend-expect';

const jsdom = new JSDOM('<!doctype html><html><body><div id="main"></div></body></html>', { url: 'https://localhost/ui/v1' });
const { window } = jsdom;

fetch.enableMocks();

// TODO: Determine whether we need to uncomment the lines below, or if things work without them
// global.document = window.document;
// global.requestAnimationFrame = function (callback) { return setTimeout(callback, 0); };
// global.cancelAnimationFrame = function (id) { clearTimeout(id); };
// global.ace = require('ace-builds/src-min-noconflict/ace');
// window.matchMedia = window.matchMedia || function () {
//   return { matches: false, addListener() {}, removeListener() {} };
// };

global.navigator = { userAgent: 'node.js' };

function copyProps(src, target) {
  Object.defineProperties(target, {
    ...Object.getOwnPropertyDescriptors(src),
    ...Object.getOwnPropertyDescriptors(target),
  });
}
copyProps(window, global);
