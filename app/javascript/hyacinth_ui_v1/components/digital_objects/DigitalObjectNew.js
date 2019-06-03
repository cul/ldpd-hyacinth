import React from 'react';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';

export default class DigitalObjectNew extends React.Component {
  render() {
    return (
      <div>
        <ContextualNavbar lefthandLabel="&laquo; Cancel New Digital Object Creation" lefthandLabelLink="/digital-objects" />
        New!
      </div>
    );
  }
}
