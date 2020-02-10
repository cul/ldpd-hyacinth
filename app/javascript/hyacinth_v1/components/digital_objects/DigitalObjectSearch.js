import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';
import { has } from 'lodash';

import DigitalObjectList from './DigitalObjectList';

import ContextualNavbar from '../layout/ContextualNavbar';
import { digitalObject } from '../../util/hyacinth_api';

export default class DigitalObjectSearch extends React.Component {
  state = {
    digitalObjects: [],
  }

  componentDidMount() {
    digitalObject.search()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.digitalObjects = res.data.digitalObjects;
        }));
      });
  }

  render() {
    const { digitalObjects } = this.state;
    return (
      <>
        <ContextualNavbar
          title="Digital Objects"
          rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
        />
        { digitalObjects.length === 0 ? <Card header="No Digital Objects found." />
          : <DigitalObjectList className="digital-object-search-results" digitalObjects={digitalObjects} />
        }
      </>
    );
  }
}
