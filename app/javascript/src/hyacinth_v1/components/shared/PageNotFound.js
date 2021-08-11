import React from 'react';

export default class PageNotFound extends React.PureComponent {
  render() {
    return (
      <div>
        <h2>Page Not Found</h2>
        <p>
          If you were expecting to find something at this URL, please check your URL
          for typos or check with a developer.
        </p>
      </div>
    );
  }
}
