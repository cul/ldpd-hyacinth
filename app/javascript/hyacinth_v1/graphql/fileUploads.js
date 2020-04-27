import * as ActiveStorage from 'activestorage';

const uploadFile = (file, url, onProgress) => {
  const delegate = {
    directUploadWillCreateBlobWithXHR: (request) => { console.debug(request); },
    directUploadWillStoreFileWithXHR: (request) => {
      request.upload.addEventListener('progress', (event) => {
        onProgress(Math.round(event.loaded * 100 / event.total));
      });
      console.debug(request);
    },
  };
  const directUpload = new ActiveStorage.DirectUpload(file, url, delegate);
  return new Promise((resolve, reject) => {
    directUpload.create((error, props) => {
      if (error) {
        reject(error);
      } else {
        resolve(props);
      }
    });
  });
};

export default uploadFile;
