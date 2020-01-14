import * as ActiveStorage from 'activestorage';

const uploadFile = (file, url) => {
  const delegate = {
    directUploadWillCreateBlobWithXHR: (data) => { console.debug(data); },
    directUploadWillStoreFileWithXHR: (data) => { console.debug(data); },
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
