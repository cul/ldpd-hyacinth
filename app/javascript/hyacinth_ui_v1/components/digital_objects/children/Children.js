import React from 'react';
import produce from 'immer';

import digitalObjectInterface from '../digitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';

class Children extends React.Component {
  // state = {
  //   digitalObject: {},
  // }

  // componentDidMount() {
  //   const { match: { params: { id } } } = this.props;
  //
  //   digitalObject.get(id)
  //     .then((res) => {
  //       console.log(res.data);
  //       this.setState(produce((draft) => {
  //         draft.digitalObject = res.data.digitalObject;
  //       }));
  //     });
  // }

  render() {
    const { data: { uid } } = this.props;

    return (
      <>
        <TabHeading>Manage Child Assets</TabHeading>
        <p>Child Digital Objects</p>
        <p># Total</p>


      </>
    );
  }
}

export default digitalObjectInterface(Children);
