import React from 'react';
import { Link } from 'react-router-dom';
import produce from 'immer';

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

        <h4>Rights Module Mockups</h4>

        {
          [
            { id: 'asset1', title: 'Example Asset' },
            { id: 'cul_q83bk3jc9s', title: 'Oral history interview with Alan Pifer and Eli Evans 1970' },
            { id: 'cul_vdncjsxn7t', title: 'Photograph of Andrew Carnegie at His Desk' },
            { id: 'cul_bnzs7h45zq', title: 'ABC News - Brian Ross Investigates: The Blueberry Children, Carnegie Fellows 2009' }
          ].map(link => (
            <Link to={`/digital_objects/${link.id}/rights/edit`} key={link.id} className="nav-link">{link.title}</Link>
          ))
        }

        <hr />

        {
          digitalObjects.map(d => (
            <Link to={`/digital_objects/${d.uid}`} key={d.uid} className="nav-link">{d.uid}</Link>
          ))
        }
      </>
    );
  }
}
