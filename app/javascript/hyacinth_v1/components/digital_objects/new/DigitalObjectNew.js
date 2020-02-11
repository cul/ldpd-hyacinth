import React, { useState } from 'react';
import { Col, Form, Collapse } from 'react-bootstrap';
import { capitalize } from 'lodash';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../../shared/ContextualNavbar';
import SubmitButton from '../../shared/forms/buttons/SubmitButton';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import Label from '../../shared/forms/Label';
import InputGroup from '../../shared/forms/InputGroup';
import SelectCreatablePrimaryProject from '../primary_project/SelectCreatablePrimaryProject';

function DigitalObjectNew() {
  const [primaryProject, setPrimaryProject] = useState(null);
  const [digitalObjectType, setDigitalObjectType] = useState(null);
  const history = useHistory();

  const onSubmitHandler = (event) => {
    event.preventDefault();
    history.push(`/digital_objects/new/${primaryProject.stringKey}/${digitalObjectType}`);
  };

  const renderDigitalObjectTypeSelect = () => {
    if (!primaryProject) return '';

    return (
      <Collapse in={primaryProject != null}>
        <div>
          <InputGroup>
            <Label sm={3}>Digital Object Type</Label>
            <SelectInput
              sm={9}
              inputName="digitalObjectType"
              value={digitalObjectType || ''}
              onChange={(selectedValue) => { setDigitalObjectType(selectedValue); }}
              options={primaryProject.enabledDigitalObjectTypes.filter(
                type => type !== 'asset',
              ).map(
                type => ({ value: type, label: capitalize(type) }),
              )}
            />
          </InputGroup>

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
        </div>
      </Collapse>
    );
  };

  return (
    <>
      <ContextualNavbar
        title="Create Digital Object"
        rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
      />

      <Form className="m-3">
        <SelectCreatablePrimaryProject
          primaryProject={primaryProject}
          changeHandler={(selectedProject) => { setPrimaryProject(selectedProject); }}
        />

        { renderDigitalObjectTypeSelect() }

      </Form>
    </>
  );
}

export default DigitalObjectNew;
