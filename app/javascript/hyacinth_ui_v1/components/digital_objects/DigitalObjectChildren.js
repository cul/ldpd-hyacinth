import React from 'react';
import produce from 'immer';

class DigitalObjectChildren extends React.Component {
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
        <p>Child Digital Objects</p>
        <p># Total</p>


      </>
    );
  }
}

export default DigitalObjectChildren;
