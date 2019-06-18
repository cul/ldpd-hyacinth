import React from 'react';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import { digitalObject } from '../../util/hyacinth_api';

class DigitalObjectChildren extends React.Component {
  state = {
    digitalObject: {},
  }

  componentDidMount() {
    const { match: { params: { id } } } = this.props;

    digitalObject.get(id)
      .then((res) => {
        console.log(res.data);
        this.setState(produce((draft) => {
          draft.digitalObject = res.data.digitalObject;
        }));
      });
  }

  render() {
    const { digitalObject: { uid } } = this.state;

    return (
      <>
        <ContextualNavbar
          title="Item: Really Long Title Goes Here When I Figure Out How Dynamic Fields Work"
          rightHandLinks={[{ link: `/digital_objects/${uid}`, label: '<< Back to Item' }]}
        />

        <h3>Child Digital Objects</h3>
        <p>Item</p>
        <p>Project</p>
        <p>PID</p>

        <hr />
        <p>Child Digital Objects</p>
        <p># Total</p>


      </>
    );
  }
}

export default DigitalObjectChildren;
