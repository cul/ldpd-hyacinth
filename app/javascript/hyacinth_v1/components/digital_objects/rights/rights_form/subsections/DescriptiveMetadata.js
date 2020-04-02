import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import ReadOnlyInput from '../../../../shared/forms/inputs/ReadOnlyInput';
import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import Field from '../fields/Field';

function DescriptiveMetadata(props) {
  const {
    onChange,
    values: [value],
    dynamicFieldData,
    typeOfContentChange,
    fieldConfig
  } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    if (fieldName === 'type_of_content') typeOfContentChange(fieldVal);

    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  return (
    <Card className="my-2">
      <Card.Header>
        Descriptive Metadata
      </Card.Header>
      <Card.Body>
        <Field
          value={value.type_of_content}
          onChange={v => onChangeHandler('type_of_content', v)}
          dynamicField={fieldConfig.children.find(c => c.stringKey === 'type_of_content')}
        />

        {
          (dynamicFieldData.genre || [{}]).map((g, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Specific Genre of Work</Label>
              <ReadOnlyInput sm={8} value={g.term ? g.term.prefLabel : ''} />
            </InputGroup>
          ))
        }

        {
          (dynamicFieldData.form || [{}]).map((f, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Form</Label>
              <ReadOnlyInput sm={8} value={f.term ? f.term.prefLabel : ''} />
            </InputGroup>
          ))
        }

        {
          (dynamicFieldData.name || [{}]).map((n, i) => (
            <Card className="my-3" key={i}>
              <Card.Header>{`Creator ${i + 1}`}</Card.Header>
              <Card.Body>
                <InputGroup>
                  <Label sm={4} align="right">Name</Label>
                  <ReadOnlyInput sm={8} value={n.term ? n.term.prefLabel : ''} />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Role(s)</Label>
                  <ReadOnlyInput sm={8} value={n.role ? n.role.map(r => r.term.prefLabel).join(', ') : ''} />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Date of Birth</Label>
                  <ReadOnlyInput sm={8} value="" />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Date of Death</Label>
                  <ReadOnlyInput sm={8} value="" />
                </InputGroup>
              </Card.Body>
            </Card>
          ))
        }

        {
          (dynamicFieldData.title || [{}]).map((t, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Title</Label>
              <ReadOnlyInput sm={8} value={t.sortPortion} />
            </InputGroup>
          ))
        }

        {
          (dynamicFieldData.alternativeTitle || [{}]).map((t, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Alternate Title</Label>
              <ReadOnlyInput sm={8} value={t.value} />
            </InputGroup>
          ))
        }

        <Field
          value={value.country_of_origin}
          onChange={v => onChangeHandler('country_of_origin', v)}
          dynamicField={fieldConfig.children.find(c => c.stringKey === 'country_of_origin')}
        />

        {
          (dynamicFieldData.publisher || [{}]).map((t, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Publisher Name</Label>
              <ReadOnlyInput sm={8} value={t.value} />
            </InputGroup>
          ))
        }

        {
          (dynamicFieldData.dateCreated || [{}]).map((d, i) => (
            <Card className="my-3" key={i}>
              <Card.Header>{`Date of Creation ${i + 1}`}</Card.Header>
              <Card.Body>
                <InputGroup>
                  <Label sm={4} align="right">Start Date</Label>
                  <ReadOnlyInput sm={8} value={d.startValue} />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">End Date</Label>
                  <ReadOnlyInput sm={8} value={d.endValue} />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Type</Label>
                  <ReadOnlyInput sm={8} value={d.type} />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Key Date</Label>
                  <ReadOnlyInput sm={8} value={d.keyDate} />
                </InputGroup>
              </Card.Body>
            </Card>
          ))
        }

        {
          (dynamicFieldData.dateCreatedTextual || [{}]).map((t, i) => (
            <InputGroup key={i}>
              <Label sm={4} align="right">Descriptive Date</Label>
              <ReadOnlyInput sm={8} value={t.value} />
            </InputGroup>
          ))
        }

        <Collapse in={value.type_of_content === 'motion_picture'}>
          <div>
            <Field
              value={value.film_distributed_to_public}
              onChange={v => onChangeHandler('film_distributed_to_public', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'film_distributed_to_public')}
            />

            <Field
              value={value.film_distributed_commercially}
              onChange={v => onChangeHandler('film_distributed_commercially', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'film_distributed_commercially')}
            />
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

DescriptiveMetadata.propTypes = {
  onChange: PropTypes.func.isRequired,
  dynamicFieldData: PropTypes.any, // or dynamicFieldData
  // values: PropTypes.arrayOf(PropTypes.shape({
  //   color: PropTypes.string,
  //   fontSize: PropTypes.number
  // })).isRequired,
};

export default DescriptiveMetadata;
