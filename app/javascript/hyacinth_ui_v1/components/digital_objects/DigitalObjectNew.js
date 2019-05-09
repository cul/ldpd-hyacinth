import React from 'react';
import { Link } from 'react-router-dom';
import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';

export default class DigitalObjectNew extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <ContextualNavbar lefthandLabel="&laquo; Cancel New Digital Object Creation" lefthandLabelLink="/digital-objects" />
        New!
      </div>
    );
  }
}
