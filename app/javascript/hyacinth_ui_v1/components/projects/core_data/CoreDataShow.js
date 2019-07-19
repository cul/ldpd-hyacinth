import React from 'react';
import { Row, Col } from 'react-bootstrap';
import produce from 'immer';

import TabHeading from '../../ui/tabs/TabHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import { Can } from '../../../util/ability_context';
import EditButton from '../../ui/buttons/EditButton';

class CoreDataShow extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: '',
    },
  }

  componentDidMount() {
    const { match: { params: { stringKey } } } = this.props;

    hyacinthApi.get(`/projects/${stringKey}`)
      .then((res) => {
        const { project } = res.data;

        this.setState(produce((draft) => {
          draft.project = project;
        }));
      });
  }

  render() {
    const { project: { stringKey, displayLabel, projectUrl } } = this.state;

    return (
      <>
        <TabHeading>
          Core Data
          <Can I="edit" of={{ subjectType: 'Project', stringKey }}>
            <EditButton
              className="float-right"
              size="lg"
              link={`/projects/${stringKey}/core_data/edit`}
            />
          </Can>
        </TabHeading>

        <Row as="dl">
          <Col as="dt" sm={2}>String Key</Col>
          <Col as="dd" sm={10}>{stringKey}</Col>

          <Col as="dt" sm={2}>Display Label</Col>
          <Col as="dd" sm={10}>{displayLabel}</Col>

          <Col as="dt" sm={2}>Project URL</Col>
          <Col as="dd" sm={10}>{projectUrl}</Col>
        </Row>
      </>
    );
  }
}

export default withErrorHandler(CoreDataShow, hyacinthApi);
