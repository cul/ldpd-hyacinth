// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

const registerImageAuthServiceWorker = async () => {
  // console.log('registerServiceWorker called');

  // Code below only runs if the browser supports service workers
  if ("serviceWorker" in navigator) {
    try {
      const workerScriptPath = "/image-auth-service-worker.js";

      let registration = await navigator.serviceWorker.register(workerScriptPath, {
        scope: "/",
      });
      await navigator.serviceWorker.ready;

      // registration.active.postMessage("Test message sent immediately after creation");

      // The `if` statement below handles browser hard refreshes, where the service worker doesn't
      // actually start running after a hard refresh.  This triggers a regular refresh of the page,
      // which starts the service worker properly.
      if (registration.active && !navigator.serviceWorker.controller) {
        // Perform a soft reload to load everything from the SW and get
        // a consistent set of resources.
        window.location.reload();
      }

      registration.active.postMessage({
        type: 'setImageServerUrl',
        url: Hyacinth.imageServerUrl,
      });

      window.addEventListener('registerAuthToken', (e) => {
        console.log("Received registerAuthToken event");
        registration.active.postMessage({
          type: 'registerAuthToken',
          identifier: e.detail.identifier,
          token: e.detail.token
        });
      });
    } catch (error) {
      console.error(`Service worker registration failed with error: ${error}`);
    }
  }
  else {
    console.log("Unable to create a service worker because navigator.serviceWorker returned a falsy value.");
  }
};
registerImageAuthServiceWorker();

setTimeout(() => {
  window.dispatchEvent(new CustomEvent('registerAuthToken', {
    detail: {
      identifier: 'test:h18931zcsk',
      token: 'public'
    }
  }));
}, 1000);
