import * as ActiveStorage from 'activestorage';

const uploadFile = (file, url, onProgress) => {
  const delegate = {
    directUploadWillStoreFileWithXHR: (request) => {
      request.upload.addEventListener('progress', (event) => {
        onProgress(Math.round(event.loaded * 100 / event.total));
      });
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
