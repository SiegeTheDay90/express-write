/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var _scripts_LoadingBar__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./scripts/LoadingBar */ \"./src/scripts/LoadingBar.js\");\n/* harmony import */ var _scripts_NoticeBalloon__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./scripts/NoticeBalloon */ \"./src/scripts/NoticeBalloon.js\");\n/* harmony import */ var _styles_scss__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./styles.scss */ \"./src/styles.scss\");\n\n\n\ndocument.addEventListener(\"DOMContentLoaded\", () => {\n  Array.from(document.getElementsByClassName('ajaxForm'))?.forEach(form => {\n    form.addEventListener('submit', _scripts_LoadingBar__WEBPACK_IMPORTED_MODULE_0__.ajaxSubmit);\n  });\n  const alertContainer = document.getElementById(\"alert-container\");\n  Array.from(document.getElementsByClassName('balloon-message'))?.forEach(message => {\n    new _scripts_NoticeBalloon__WEBPACK_IMPORTED_MODULE_1__[\"default\"](alertContainer, message.dataset.type, message.dataset.text);\n  });\n});\n\n//# sourceURL=webpack://write-wise/./src/index.js?");

/***/ }),

/***/ "./src/scripts/LoadingBar.js":
/*!***********************************!*\
  !*** ./src/scripts/LoadingBar.js ***!
  \***********************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   ajaxSubmit: () => (/* binding */ ajaxSubmit)\n/* harmony export */ });\n/* harmony import */ var _NoticeBalloon__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./NoticeBalloon */ \"./src/scripts/NoticeBalloon.js\");\n\nclass LoadingBar {\n  constructor(form, url, options = {}, action, completionCallback) {\n    this.bar = document.createElement('progress');\n    this.status = document.createElement('span');\n    this.statusBox = document.createElement('p');\n    this.loadingImage = new Image();\n    this.loadingImage.src = [\"https://cl-helper-development.s3.amazonaws.com/loading-box.gif\", \"https://cl-helper-development.s3.amazonaws.com/loading-ball.gif\"][Math.floor(Math.random() * 2)];\n    this.loadingImage.id = \"loading-gif\";\n    this.container = form.parentElement;\n    this.originalForm = form;\n    form.remove();\n    this.action = action;\n    this.complete = 0;\n    this.timeElapsed = 0;\n    this.resourceId;\n    this.progressMessages = [\"Dipping pen...\", \"Mixing Ink...\", \"Ruffling paper...\"];\n    this.defaultMessage = \"Writing... This can take a few minutes.\";\n    this.completionCallback ||= completionCallback;\n    this.container.append(this.bar);\n    this.statusBox.append(this.status);\n    this.statusBox.append(this.loadingImage);\n    this.container.append(this.statusBox);\n    this.bar.innerText = 0;\n    this.bar.max = 100;\n    this.status.innerHTML = \"Getting Started...\";\n    // options[\"authenticity_token\"] = \"<%= form_authenticity_token %>\";\n    fetch(url, options).then(res => this.loadingCallback(res)).catch(this.failureCallback);\n  }\n  incComplete(num) {\n    this.complete += num;\n    this.bar.innerText = this.complete;\n    this.bar.value = this.complete;\n  }\n  async loadingCallback(response) {\n    if (response.ok) {\n      const data = await response.json(); // Parse API response\n      this.request_id = data.id; // Request_id from backend\n\n      this.interval = setInterval(async () => {\n        // Ping backend until request is complete\n        const response = await fetch(`/check/${this.request_id}`);\n        const data = await response.json();\n        if (data.complete) {\n          // Request complete\n          clearInterval(this.interval);\n          if (data.ok) {\n            // Success\n            this.messages = data.messages;\n            this.completionCallback(data.resource_id);\n          } else {\n            // Failure\n            this.failureCallback(JSON.parse(data.messages));\n          }\n        } else if (this.timeElapsed > 240) {\n          // Timeout\n          clearInterval(this.interval);\n          this.failureCallback(\"Timeout\");\n        }\n        this.status.innerText = this.progressMessages.length ? this.progressMessages.pop() : this.defaultMessage;\n        this.timeElapsed += 5;\n      }, 5000);\n    }\n  }\n  async completionCallback(id) {\n    this.complete = 100;\n    this.bar.innerText = 100;\n    this.bar.value = 100;\n    let count = 5;\n    let bio;\n    let params;\n    this.status.innerText = `Complete! Redirecting in ${count}.....`;\n    switch (this.action) {\n      case \"listings#generate\":\n        this.nextPath = `/listings/${id}/`;\n        break;\n      case \"letters#generate\":\n        this.nextPath = `/letters/${id}/`;\n        break;\n      case \"profiles#new\":\n        bio = JSON.parse(this.messages);\n        params = new URLSearchParams(bio).toString();\n        this.nextPath = `/profiles/new?` + params;\n        break;\n      case \"profiles#edit\":\n        bio = JSON.parse(this.messages);\n        params = new URLSearchParams(bio).toString();\n        this.nextPath = `/profiles/${id}/edit?` + params + \"&m=Profile+Not+Yet+Saved\";\n        break;\n      case \"express#generate\":\n        this.nextPath = `/temp/${id}`;\n        break;\n      case \"express-member#generate\":\n        this.nextPath = `/letters/${id}`;\n        break;\n      default:\n        this.nextPath = \"/\";\n    }\n    setTimeout(() => {\n      window.location.href = window.location.origin + this.nextPath;\n    }, 5000);\n    setInterval(() => {\n      this.status.innerText = `Complete! Redirecting in ${--count}` + '.'.repeat(count);\n    }, 990);\n  }\n  failureCallback(errors) {\n    console.error(\"Request Failed: \", errors.join(\"\\n\"));\n    const alertContainer = document.getElementById(\"alert-container\");\n    errors.forEach(error => {\n      new _NoticeBalloon__WEBPACK_IMPORTED_MODULE_0__[\"default\"](alertContainer, \"error\", error);\n    });\n    this.status.innerText = \"ERROR\";\n    const tryAgain = document.createElement(\"button\");\n    tryAgain.classList.add(\"btn\");\n    tryAgain.classList.add(\"btn-primary\");\n    tryAgain.innerText = \"Try Again?\";\n    tryAgain.addEventListener(\"click\", e => {\n      this.container.append(this.originalForm);\n      this.bar.remove();\n      this.status.remove();\n      this.loadingImage.remove();\n      tryAgain.remove();\n    });\n    this.container.append(tryAgain);\n  }\n}\nconst ajaxSubmit = function (e) {\n  e.preventDefault();\n  const form = e.target;\n  const method = form.querySelector(\"input[name=_method]\") ? form.querySelector(\"input[name=_method]\").value : form.method || \"GET\";\n  const options = {\n    method,\n    body: {},\n    headers: {}\n  };\n  options.headers[\"Content-Type\"] = \"application/json\";\n  const inputs = form.querySelectorAll(\"input, textarea, select\");\n  let queryParams = new URLSearchParams();\n  inputs.forEach(input => {\n    if (!input.name) return;\n    switch (input.type) {\n      case \"radio\":\n        if (input.checked) queryParams.append(input.name, input.value);\n        break;\n      case \"file\":\n        if (options.body[\"link\"]) break;\n        // options.body = new FormData();\n        options.body = input.files[0];\n        // options.body.append('file', input.files[0]);\n        const type = document.getElementById(\"resume-format\").value;\n        if (type === \"PDF\") {\n          options.headers[\"Content-Type\"] = 'application/pdf';\n          queryParams.append(\"resume-format\", \"PDF\");\n        } else if (type === \"DOCX\") {\n          options.headers[\"Content-Type\"] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';\n          queryParams.append(\"resume-format\", \"DOCX\");\n        }\n        break;\n      default:\n        if (input.name === \"authenticity_token\") {\n          options.headers[\"X-CSRF-Token\"] = input.value;\n        } else {\n          queryParams.append(input.name, input.value);\n          // options.body[input.name] = input.value\n        }\n        ;\n    }\n  });\n  if (options.headers[\"Content-Type\"] === \"application/json\") options.body = JSON.stringify(options.body);\n  new LoadingBar(form,\n  //Form Element to be relplaced\n  form.action + \"?\" + queryParams.toString(),\n  // Fetch URL\n  options,\n  // Method, Body, Headers\n  form.dataset?.action // i.e. data-action=\"letters#generate\"\n  );\n};\n\nasync function isValidURL(url) {\n  // Regular expression pattern to match URLs\n  const urlPattern = /(https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9]+\\.[^\\s]{2,}|www\\.[a-zA-Z0-9]+\\.[^\\s]{2,})/;\n  if (!urlPattern.test(url)) {\n    return false;\n  }\n  try {\n    await fetch(url, {\n      mode: 'no-cors'\n    });\n    return true;\n  } catch {\n    return false;\n  }\n}\nasync function checkValidSite(input, button) {\n  let url = input.value;\n  input.disabled = true;\n  const loadingImage = new Image();\n  loadingImage.src = [\"https://cl-helper-development.s3.amazonaws.com/loading-box.gif\", \"https://cl-helper-development.s3.amazonaws.com/loading-ball.gif\"][Math.floor(Math.random() * 2)];\n  loadingImage.id = \"loading-gif\";\n  button.parentElement.appendChild(loadingImage);\n  const statusDiv = document.getElementById('status');\n  if (url.slice(0, 4).toLowerCase() !== \"http\") {\n    url = \"https://\" + url;\n  }\n  if (!(await isValidURL(url))) {\n    statusDiv.classList.add('text-danger');\n    statusDiv.classList.remove('text-sucess');\n    statusDiv.innerHTML = `❌ Not a valid URL`;\n  } else {\n    const response = await fetch(`/url-check/?url=${url}`);\n    const {\n      ok,\n      status\n    } = await response.json();\n    if (ok === true) {\n      button.disabled = false;\n      statusDiv.innerHTML = `✅`;\n      statusDiv.classList.add('text-success');\n      statusDiv.classList.remove('text-danger');\n    } else {\n      button.disabled = true;\n      statusDiv.classList.remove('text-sucess');\n      statusDiv.classList.add('text-danger');\n      statusDiv.innerHTML = `❌ ${status}`;\n    }\n  }\n  input.disabled = false;\n  loadingImage.remove();\n}\nfunction listingInputChange(e = event) {\n  if (localStorage.getItem('debounce')) {\n    clearTimeout(localStorage.getItem('debounce'));\n  }\n  const type = Array.from(document.querySelectorAll(\"input[type=radio]\")).filter(radio => radio.checked)[0].value;\n  const input = document.getElementById(\"text-input\");\n  const submit = document.getElementById(\"express-submit\");\n  submit.disabled = true;\n  if (input.value === \"\") return;\n  if (e.target.type === \"radio\") {\n    input.value = \"\";\n  } else {\n    if (type === 'url') {\n      const debounce = setTimeout(() => {\n        checkValidSite(input, submit);\n      }, 500);\n      localStorage.setItem('debounce', debounce);\n    } else {\n      if (e.target.value.trim()) {\n        submit.disabled = false;\n      } else {\n        submit.disabled = true;\n      }\n    }\n  }\n}\n\n//# sourceURL=webpack://write-wise/./src/scripts/LoadingBar.js?");

/***/ }),

/***/ "./src/scripts/NoticeBalloon.js":
/*!**************************************!*\
  !*** ./src/scripts/NoticeBalloon.js ***!
  \**************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__)\n/* harmony export */ });\nclass NoticeBalloon {\n  constructor(container, type = \"notice\", message) {\n    this.type = type;\n    this.parent = container;\n    this.balloon = document.createElement(\"div\");\n    this.balloon.style.position = \"relative\";\n    this.balloon.classList.add(\"balloon\");\n    this.balloon.classList.add(this.type === \"error\" ? \"text-danger\" : \"text-info\");\n    this.balloon.classList.add(type);\n    this.balloon.innerText = message;\n    if (this.type === \"error\") {\n      const reportButton = document.createElement(\"span\");\n      reportButton.innerHTML = `<a href=\"/bug-report?${new URLSearchParams({\n        error: message\n      })}\">Report</a>`;\n      reportButton.style.position = \"absolute\";\n      reportButton.style.right = \"7px\";\n      reportButton.style.bottom = \"4px\";\n      this.balloon.appendChild(reportButton);\n    }\n    this.closeButton = document.createElement(\"span\");\n    this.balloon.appendChild(this.closeButton);\n    this.closeButton.classList.add(\"close-button\");\n    this.close = this.close.bind(this);\n    this.closeButton.addEventListener('click', this.close);\n    this.opacity = 1;\n    this.parent.appendChild(this.balloon);\n  }\n  close(e) {\n    this.interval = setInterval(() => {\n      if (this.opacity > 0) {\n        this.opacity -= 0.1;\n        this.balloon.style.opacity = this.opacity;\n      } else {\n        this.balloon.remove();\n        clearInterval(this.interval);\n      }\n    }, 20);\n  }\n}\n/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (NoticeBalloon);\n\n//# sourceURL=webpack://write-wise/./src/scripts/NoticeBalloon.js?");

/***/ }),

/***/ "./src/styles.scss":
/*!*************************!*\
  !*** ./src/styles.scss ***!
  \*************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n// extracted by mini-css-extract-plugin\n\n\n//# sourceURL=webpack://write-wise/./src/styles.scss?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = __webpack_require__("./src/index.js");
/******/ 	
/******/ })()
;