import React from 'react';
import produce from 'immer';
import { Table, Button } from 'react-bootstrap';

import digitalObjectInterface from '../digitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';

class PreservePublish extends React.Component {
  state = {
    publishTargets: [],
  }

  componentDidMount() {
    const { match: { params: { id } } } = this.props;
    // Retrive publish targets from all projects

    // digitalObject.get(id)
    //   .then((res) => {
    //     console.log(res.data);
    //     this.setState(produce((draft) => {
    //       draft.digitalObject = res.data.digitalObject;
    //     }));
    //   });
  }

  render() {
    const { publishTargets } = this.state;

    return (
      <>
        <TabHeading>
          Preserve
        </TabHeading>
        <p>Paragraph describing what preserving means?</p>

        <Button>Preserve</Button>

        <hr />

        {
          publishTargets && (
            <>
              <TabHeading>
                Perserve & Publish
              </TabHeading>
              <p>Currently published to: </p>

              <Table>

              </Table>
              <Button>Perserve & Publish</Button>
            </>
          )
        }
      </>
    );
  }
}

export default digitalObjectInterface(PreservePublish);
