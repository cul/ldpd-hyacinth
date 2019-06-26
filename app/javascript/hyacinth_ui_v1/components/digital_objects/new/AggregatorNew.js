import React from 'react';
import produce from 'immer';
import {
  Row, Col, Form,
} from 'react-bootstrap';

import ContextualNavbar from '../../layout/ContextualNavbar';
import hyacinthApi, { digitalObject } from '../../../util/hyacinth_api';
import SubmitButton from '../../layout/forms/SubmitButton';
import MetadataForm from '../metadata/MetadataForm';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import DigitalObjectSummary from '../DigitalObjectSummary';

class AggregatorNew extends React.PureComponent {
  state = {
    digitalObject: {
      digitalObjectDataJson: {
        serializationVersion: '1',
        projects: [{
          stringKey: '',
        }],
        digitalObjectType: '',
        dynamicFieldData: {},
      },
    },
  }

  componentDidMount = () => {
    const { project, digitalObjectType } = this.props;

    this.setState(produce((draft) => {
      draft.digitalObject.digitalObjectDataJson.projects[0].stringKey = project;
      draft.digitalObject.digitalObjectDataJson.digitalObjectType = digitalObjectType;
    }));

    // Get Project Display Label
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { digitalObject: data } = this.state;
    // const { history: { push } } = this.props;

    digitalObject.create(data)
      .then(res => console.log(res.data)); //push(`/digital_objects/${res.data.id}/edit`)
  }

  render() {
    const { project, digitalObjectType } = this.props;
    const { dynamicFields } = this.state;

    return (
      <>
        <ContextualNavbar
          title={`New ${digitalObjectType}`}
          rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
        />

        <DigitalObjectSummary
          data={{ projects: [{ stringKey: project, displayLabel: project }] }}
        />
        {/* <p>Project: {project}</p>
        <p>UID: - Assigned After Save -</p>
        <p>DOI: Unavailable</p> */}

        <Form>
          <MetadataForm
            projects={[{ stringKey: project }]}
            digitalObjectType={digitalObjectType}
            dynamicFieldData={{}}
          />
          <Row>
            <Col sm="auto" className="ml-auto">
              <SubmitButton onClick={this.onSubmitHandler} formType="new" />
            </Col>
          </Row>
        </Form>

      </>
    );
  }
}

export default withErrorHandler(AggregatorNew, hyacinthApi);
