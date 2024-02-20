console.log("Image auth service worker started running at: " + new Date().getTime());

let imageServerUrl = null;
const pidsToTokens = new Map();
const iiifUrlWithRequiredAuthRegex = /.+\/iiif\/2\/(standard|limited)\/([^/]+)\/.+/;

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function registerAuthToken(identifier, token) {
  // TODO: Also clear out some old tokens (with addedAt time that's far in the past) so that
  // the pidsToTokens Map doesn't grow indefinitely.
  pidsToTokens.set(
    identifier,
    {
      token: token,
      addedAt: Date.now()
    }
  );
};

async function checkForAuthToken(identifier) {
  console.log(`Checking for ${identifier}`);
  const start = Date.now();
  const checkDelayTimes = [0, 100, 3000]; // [100, 200]
  for (const delayTime of checkDelayTimes) {
    await sleep(delayTime);
    console.log(`Checking for ${identifier} in pidsToTokens Map after ${delayTime} millisecond delay.`);
    if (pidsToTokens.has(identifier)) {
      return pidsToTokens.get(identifier);
    }
  }
  return null;
}

async function fetchWithAuthorizationHeader(request) {

  console.log(`Adding header to request: ${request.url}`);
  const identifier = request.url.match(iiifUrlWithRequiredAuthRegex)[2];

  // Check if there is a token available for this identifier
  const entry = await checkForAuthToken(identifier);
  const headers = new Headers(request.headers);
  if (entry) {
    console.log(`Making request with token ${entry.token}`);
    headers.set('Authorization', `Bearer ${entry.token}`);
  } else {
    headers.set('Authorization', `Bearer no-token`); // TODO: This isn't actually needed, so we can delete it.
  }

  const newRequest = new Request(request, {
    mode: 'cors',
    credentials: 'omit',
    headers: headers
  });

  return fetch(newRequest);
}

self.addEventListener('fetch', function (event) {
  const url = event.request.url;
  // console.log(`imageServerUrl: ${imageServerUrl}`);
  // console.log(`Intercepting fetch request for: ${url}`);
  if (url.startsWith(imageServerUrl) && url.match(iiifUrlWithRequiredAuthRegex)) {
    event.respondWith(fetchWithAuthorizationHeader(event.request));
  }
});

self.addEventListener("message", (event) => {
  const { data } = event;
  console.log('Service worker received message: ', data);

  if (data.type == 'registerAuthToken') {
    registerAuthToken(data.identifier, data.token);
  }

  if (data.type == 'setImageServerUrl') {
    imageServerUrl = data.url;
  }
});
