import React from 'react';
import { Link } from 'react-router-dom';
import produce from 'immer';
import { has } from 'lodash';

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

  titleForDigitalObject = (digObj) => {
    let title = '[No Title]';
    if (has(digObj, 'dynamicFieldData.title[0]')) {
      const titleData = digObj.dynamicFieldData.title[0];
      title = titleData.titleSortPortion;
      if (titleData.titleNonSortPortion) {
        title = `${titleData.titleNonSortPortion} ${title}`;
      }
    }
    return title;
  }

  render() {
    const { digitalObjects } = this.state;
    return (
      <>
        <ContextualNavbar
          title="Digital Objects"
          rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
        />
        <div className="digital-object-search-results">
          { digitalObjects.length === 0 ? 'No Digital Objects found.'
            : digitalObjects.map((d, i) => (
              <div className={`search-result card mb-2 ${i % 2 === 0 ? 'bg-light' : ''}`} key={d.uid}>
                <div className="card-body">
                  <div>
                    <strong><Link to={`/digital_objects/${d.uid}`}>{this.titleForDigitalObject(d)}</Link></strong>
                  </div>
                  <div>
                    <strong>UID:</strong>
                    &nbsp;
                    {d.uid}
                  </div>
                </div>
              </div>
            ))
          }
        </div>
      </>
    );
  }
}
