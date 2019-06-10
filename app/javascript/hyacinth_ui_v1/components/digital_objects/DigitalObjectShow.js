import React from 'react';
import { Link } from 'react-router-dom';

import ItemShow from './item/ItemShow';

export default class DigitalObjectShow extends React.Component {
  componentDidMount() {
    // TODO: load data for digital object
    console.log(`Component mounted. uuid: ${this.props.match.params.uuid}`);
    // fetchDigitalObject()
  }

  fetchDigitalObject() {

  }

  render() {
    return (
      <ItemShow />
    );
  }


}
