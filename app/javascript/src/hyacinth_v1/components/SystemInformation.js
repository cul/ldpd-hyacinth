import React, { useState, useEffect } from 'react';
import ContextualNavbar from './shared/ContextualNavbar';

const SystemInformation = () => {
  const [version, setVersion] = useState('');

  useEffect(() => {
    setVersion(document.body.getAttribute('data-hyacinth-version'));
  }, []);

  return (
    <>
      <ContextualNavbar title="System Information" />
      <table className="table table-bordered table-striped">
        <thead>
          <tr>
            <th>Property</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Version</td>
            <td>{version}</td>
          </tr>
        </tbody>
      </table>
    </>
  );
};

export default SystemInformation;
