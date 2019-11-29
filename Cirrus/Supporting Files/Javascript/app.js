//
//  app.js
//  Cirrus
//
//  Copyright © 2018 Ian Spence. All rights reserved.
//  This file is shared for auditing purposes only and is not designed
//  for use outside of the Cirrus software.
//

// This debugger statement allows users (like you!) to inspect the injected application
// javascript. If you have any questions or commented regarding this code please do not
// hesitate to get in touch at https://cirrus-app.com/support.html
debugger;

// These values need to be kept *NSYNC with those in LoginWebViewController.c
var EVENT_INPUT_FOUND = 'EVENT_INPUT_FOUND',
    EVENT_PRESS_BUTTON = 'EVENT_PRESS_BUTTON',
    EVENT_SOLVE_CAPTCHA = 'EVENT_SOLVE_CAPTCHA',
    EVENT_ERROR = 'EVENT_ERROR',
    EVENT_EMAIL_VALUE = 'EVENT_EMAIL_VALUE',
    EVENT_KEY_VALUE = 'EVENT_KEY_VALUE';

// Hopefully these don't change...
var GLOBAL_API_KEY_CELL = 'Global API Key',
    BUTTON_TEXT_VIEW_KEY = 'View';

function hideSalesLink() {
    // In accordance with App Review Guideline 3.1.1
    // We cannot show any link to external purchasing mechanisms outside of the
    // in-app-purchase system. According to one bad reviewer this includes phone numbers
    // and even the word "Sales" and "Plans" so we have to remove those. Might try
    // sneaking them back in later in hopes that I get a competent reviewer next time.
    var tid = setInterval(function() {
        var footer = document.getElementsByTagName('footer')[0];
        if (footer.children && footer.children[0]) {
            footer.children[0].remove();
            console.log('Footer hidden');
        }

        var links = Array.from(document.getElementsByTagName('a'));
        (links || []).forEach(function(link) {
            if (link.href === 'https://www.cloudflare.com/') {
                // Neuter the header link to prevent getting to the "sign-up" page.
                link.href = '#';
            }

            if (link.href.indexOf('a/sign-up') !== -1) {
                link.remove();
                console.log('Sign-up hidden');
                clearInterval(tid);
            }
        });
    }, 500);
}

function getEmailInput() {
    return new Promise(function(resolve) {
        var tid = setInterval(function() {
            var inputs = document.getElementsByTagName('input');
            var emailInput, input;

            // First, locate the email input based off of the input type.
            for (var i = 0, count = inputs.length; i < count; i ++) {
                input = inputs[i];
                if (input.attributes.name.value === 'email') {
                    console.log(EVENT_INPUT_FOUND);
                    window.webkit.messageHandlers.observe.postMessage(EVENT_INPUT_FOUND);
                    emailInput = input;
                    break;
                }
            }
            // If no email input was found, we're likely on the wrong page.
            if (emailInput) {
                // Sanity test to ensure we're not touching the password field
                if (emailInput.attributes.type.value === 'password') {
                    console.error(EVENT_ERROR + 'Email input was password - sanity failure');
                    window.webkit.messageHandlers.observe.postMessage(EVENT_ERROR + 'Email input was password - sanity failure');
                    return;
                }

                clearInterval(tid);
                resolve(emailInput);
            }
        }, 500);
    });
}

function getEmail() {
    getEmailInput().then(function(emailInput) {
        // Add a blur event listener that tells Cirrus its value
        emailInput.addEventListener('blur', function() {
            console.info(EVENT_EMAIL_VALUE);
            window.webkit.messageHandlers.observe.postMessage(EVENT_EMAIL_VALUE + emailInput.value);
        });
    });
}

function locateAPIKeyButton() {
    // First locate the "View Global Key" row...
    var cells = Array.from(document.getElementsByTagName('tr'));
    var child;
    cells = cells.filter(function(cell) {
        child = cell.querySelector('td');
        if (child) {
            return child.innerText === GLOBAL_API_KEY_CELL;
        }
        return false;
    });
    if (cells.length === 1) {
        // ...then locate the "View API Key" button, ensuring we don't click anything else
        var buttons = Array.from(cells[0].querySelectorAll('button'));
        buttons = buttons.filter(function(button) {
            return button.innerText === BUTTON_TEXT_VIEW_KEY;
        });
        if (buttons.length === 1) {
            console.log(EVENT_INPUT_FOUND);
            window.webkit.messageHandlers.observe.postMessage(EVENT_INPUT_FOUND);
            return buttons[0];
        }
    }
}

function locateAPITextArea() {
    var textarea = document.getElementsByTagName('textarea');
    if (textarea.length === 1 && textarea[0].attributes.class.value !== 'g-recaptcha-response') {
        return textarea[0];
    }
}

function locateCaptcha() {
    return document.getElementById('g-recaptcha');
}

function getAPIKey() {
    // Page takes a moment to render, poll until we can find the "View API Key button"
    var bid = setInterval(function() {
        var button = locateAPIKeyButton();
        if (!button) {
            return;
        }
        clearInterval(bid);

        // Scroll the button into view and notify the user to tap on the button
        // At that point, they will have to re-enter their password and solve a
        // captcha
        button.scrollIntoView();
        window.webkit.messageHandlers.observe.postMessage(EVENT_PRESS_BUTTON);

        // Locate the captcha dialog
        var vid = setInterval(function() {
            var captcha = locateCaptcha();
            if (!captcha) {
                return;
            }
            clearInterval(vid);
            console.info(EVENT_SOLVE_CAPTCHA);
            window.webkit.messageHandlers.observe.postMessage(EVENT_SOLVE_CAPTCHA);
        }, 500);

        // Locate the API key dialog
        var tid = setInterval(function() {
            var textArea = locateAPITextArea();
            if (!textArea) {
                return;
            }
            clearInterval(tid);
            var key = textArea.value;
            if (key.length === 37) {
                console.info(EVENT_KEY_VALUE);
                window.webkit.messageHandlers.observe.postMessage(EVENT_KEY_VALUE + key);
                clearInterval(tid);
            } else {
                console.error(EVENT_ERROR);
                window.webkit.messageHandlers.observe.postMessage(EVENT_ERROR);
            }
        }, 500);
    }, 500);
}

function goToAccountSettings() {
    // Do this from within javascript so that the browser retains cookies,
    // If done from the WKWebView, cookies would need to be injected manually
    window.location.href = '/a/profile';
}
