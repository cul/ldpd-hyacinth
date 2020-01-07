import React, { useState } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { useQuery } from '@apollo/react-hooks';
import { Col, Form, Collapse } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import { capitalize } from 'lodash';

import ContextualNavbar from '../layout/ContextualNavbar';
import SubmitButton from '../layout/forms/SubmitButton';
import SelectInput from '../ui/forms/inputs/SelectInput';
import Label from '../ui/forms/Label';
import InputGroup from '../ui/forms/InputGroup';
import SelectPrimaryProject from './primary_project/SelectPrimaryProject';

function DigitalObjectNew() {
  const [primaryProject, setPrimaryProject] = useState(null);
  const [digitalObjectType, setDigitalObjectType] = useState(null);

  const onSubmitHandler = (event) => {
    event.preventDefault();
  };

  return (
    <>
      <ContextualNavbar
        title="Create Digital Object"
        rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
      />

      <Form className="m-3">
        <SelectPrimaryProject
          primaryProject={primaryProject}
          changeHandler={(selectedProject) => { setPrimaryProject(selectedProject); }}
        />

        { primaryProject && (
          <Collapse in={primaryProject.stringKey !== ''}>
            <div>
              <InputGroup>
                <Label sm={3}>Digital Object Type</Label>
                <SelectInput
                  sm={9}
                  inputName="digitalObjectType"
                  value={digitalObjectType || ''}
                  onChange={(selectedValue) => { setDigitalObjectType(selectedValue); }}
                  options={primaryProject.enabledDigitalObjectTypes.filter(
                    type => type !== 'asset'
                  ).map(
                    type => ({ value: type, label: capitalize(type) })
                  )}
                />
              </InputGroup>

              <Collapse in={digitalObjectType !== ''}>
                <div>
                  <Form.Row>
                    <Col sm="auto" className="ml-auto">
                      <SubmitButton
                        formType="new"
                        onClick={onSubmitHandler}
                      />
                    </Col>
                  </Form.Row>
                </div>
              </Collapse>
            </div>
          </Collapse>
        )}

      </Form>
    </>
  );


  // const { search } = useLocation();
  // const { primaryProject, digitalObjectType } = queryString.parse(search);

  // if(primaryProject && digitalObjectType) {

  // }

  // render={(props) => {
  //   if (parent && digitalObjectType === 'asset') {
  //     return <></>;
  //   }

  //   if (primaryProject && digitalObjectType !== 'asset') {
  //     return (
  //       <AggregatorNew
  //         digitalObjectType={digitalObjectType}
  //         primaryProject={primaryProject}
  //       />
  //     );
  //   }

  //   return <DigitalObjectNew />;
  // }}



  // state = {
  //   digitalObjectTypeOptions: [
  //     { label: 'Item', value: 'item' },
  //     { label: 'Site', value: 'site' },
  //   ],
  //   digitalObject: {
  //     digitalObjectDataJson: {
  //       primaryProject: {
  //         stringKey: '',
  //       },
  //       digitalObjectType: '',
  //     },
  //   },
  // }

  // onProjectChangeHandler = (value) => {
  //   this.setState(produce((draft) => {
  //     draft.digitalObject.digitalObjectDataJson.primaryProject.stringKey = value;
  //   }));

  //   // TODO
  //   // Reload all the potential types of digital object types.
  //   // Query for all three digital object types, filter out any types that do not have any enabled
  //   // fields within the project.
  // }

  // onDigitalObjectTypeChangeHandler = (name, value) => {
  //   this.setState(produce((draft) => {
  //     draft.digitalObject.digitalObjectDataJson.digitalObjectType = value;
  //   }));
  // }

  // onSubmitHandler = (event) => {
  //   event.preventDefault();

  //   const {
  //     digitalObject: {
  //       digitalObjectDataJson: { digitalObjectType, primaryProject },
  //     },
  //   } = this.state;

  //   const { history: { push } } = this.props;

  //   push(`/digital_objects/new?primaryProject=${primaryProject.stringKey}&digitalObjectType=${digitalObjectType}`);
  // }

  //   const {
  //     digitalObjectTypeOptions,
  //     digitalObject: {
  //       digitalObjectDataJson: { digitalObjectType, primaryProject },
  //     },
  //   } = this.state;
}

// DigitalObjectNew.propTypes = {
//   history: PropTypes.object.isRequired,
// };

export default DigitalObjectNew;
