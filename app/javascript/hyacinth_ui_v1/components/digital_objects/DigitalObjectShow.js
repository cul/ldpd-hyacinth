import React from 'react';
import { Link } from 'react-router-dom';
import produce from 'immer';

import ItemShow from './show/ItemShow';
import { digitalObject } from '../../util/hyacinth_api';

export default class DigitalObjectShow extends React.Component {
  state = {
    digitalObjectData: {},
  };

  componentDidMount() {
    const { match: { params: { id } } } = this.props;

    digitalObject.get(id)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.digitalObjectData = res.data.digitalObject;
        }));
      });
  }

  render() {
    const { digitalObjectData, digitalObjectData: { digitalObjectType, uid } } = this.state;

    let template = <></>;

    switch (digitalObjectType) {
      case 'item':
        template = <ItemShow data={digitalObjectData} />;
        break;
      default:
        break;
    }

    return (template);
  }
}
