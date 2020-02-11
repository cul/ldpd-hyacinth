import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import ReadOnlyInput from '../../../../shared/forms/inputs/ReadOnlyInput';
import TermSelect from '../../../../shared/forms/inputs/TermSelect';
import YesNoSelect from '../../../../shared/forms/inputs/YesNoSelect';
import SelectInput from '../../../../shared/forms/inputs/SelectInput';
import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';

const typeOfContent = [
  { label: 'Compilation', value: 'compilation' },
  { label: 'Literary works', value: 'literary' },
  { label: 'Musical works, including any accompanying words', value: 'musical' },
  { label: 'Dramatic works, including any accompanying music', value: 'dramatic' },
  { label: 'Pantomimes and choreographic works', value: 'pantomimes_and_choreographic' },
  { label: 'Pictorial, graphic, and sculptural works', value: 'pictoral_graphic_and_scuptural' },
  { label: 'Motion pictures and other audiovisual works ', value: 'motion_picture' },
  { label: 'Sound recordings', value: 'sound_recordings' },
  { label: 'Architectural works', value: 'architectural' },
];

class DescriptiveMetadata extends React.PureComponent {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value, dynamicFieldData } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Descriptive Metadata
          </Card.Title>

          <InputGroup>
            <Label sm={4} align="right">Type of Content Subject to Copyright</Label>
            <SelectInput
              sm={8}
              value={value.typeOfContent}
              options={typeOfContent}
              onChange={v => this.onChange('typeOfContent', v)}
            />
          </InputGroup>

          {
            (dynamicFieldData.genre || [{}]).map((t, i) => (
              <InputGroup key={i}>
                <Label sm={4} align="right">Specific Genre of Work</Label>
                <ReadOnlyInput sm={8} value={t.genreTerm ? t.genreTerm.prefLabel : ''} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.form || [{}]).map((t, i) => (
              <InputGroup key={i}>
                <Label sm={4} align="right">Form</Label>
                <ReadOnlyInput sm={8} value={t.formTerm ? t.formTerm.prefLabel : ''} />
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
                    <ReadOnlyInput sm={8} value={n.nameTerm ? n.nameTerm.prefLabel : ''} />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Role(s)</Label>
                    <ReadOnlyInput sm={8} value={n.nameRole ? n.nameRole.map(r => r.nameRoleTerm.prefLabel).join(', ') : ''} />
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
                <ReadOnlyInput sm={8} value={t.titleSortPortion} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.alternativeTitle || [{}]).map((t, i) => (
              <InputGroup key={i}>
                <Label sm={4} align="right">Alternate Title</Label>
                <ReadOnlyInput sm={8} value={t.alternativeTitleValue} />
              </InputGroup>
            ))
          }

          <InputGroup>
            <Label sm={4} align="right">Country of Origin</Label>
            <TermSelect
              vocabulary="geonames"
              value={value.countryOfOrigin}
              onChange={v => this.onChange('countryOfOrigin', v)}
            />
          </InputGroup>

          {
            (dynamicFieldData.publisher || [{}]).map((t, i) => (
              <InputGroup key={i}>
                <Label sm={4} align="right">Publisher Name</Label>
                <ReadOnlyInput sm={8} value={t.publisherValue} />
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
                    <ReadOnlyInput sm={8} value={d.dateCreatedStartValue} />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">End Date</Label>
                    <ReadOnlyInput sm={8} value={d.dateCreatedEndValue} />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Type</Label>
                    <ReadOnlyInput sm={8} value={d.dateCreatedType} />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Key Date</Label>
                    <ReadOnlyInput sm={8} value={d.dateCreatedKeyDate} />
                  </InputGroup>
                </Card.Body>
              </Card>
            ))
          }

          {
            (dynamicFieldData.dateCreatedTextual || [{}]).map((t, i) => (
              <InputGroup key={i}>
                <Label sm={4} align="right">Descriptive Date</Label>
                <ReadOnlyInput sm={8} value={t.dateCreatedTextualValue} />
              </InputGroup>
            ))
          }

          <Collapse in={value.typeOfContent === 'motion_picture'}>
            <div>
              <InputGroup>
                <Label sm={4} align="right">Film distributed to public?</Label>
                <YesNoSelect
                  value={value.filmDistributedToPublic}
                  onChange={v => this.onChange('filmDistributedToPublic', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">Film distributed commercially?</Label>
                <YesNoSelect
                  value={value.filmDistributedCommercially}
                  onChange={v => this.onChange('filmDistributedCommercially', v)}
                />
              </InputGroup>
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}

DescriptiveMetadata.propTypes = {
  onChange: PropTypes.func.isRequired,
  dynamicFieldData: PropTypes.any, // or dynamicFieldData
  value: PropTypes.any,
};

export default DescriptiveMetadata;
