import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import ReadOnlyInput from '../../form/inputs/ReadOnlyInput';
import ControlledVocabularySelect from '../../form/inputs/ControlledVocabularySelect';
import YesNoSelect from '../../form/inputs/YesNoSelect';
import SelectInput from '../../form/inputs/SelectInput';
import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';

const typeOfContent = [
  { label: 'Compilation', value: 'compilation' },
  { label: 'Literary works', value: 'literary' },
  { label: 'Musical works, including any accompanying words', value: 'musical' },
  { label: 'Dramatic works, including any accompanying music', value: 'dramatic' },
  { label: 'Pantomimes and choreographic works', value: 'pantomimesAndChoreographic' },
  { label: 'Pictorial, graphic, and sculptural works', value: 'pictoralGraphicAndScuptural' },
  { label: 'Motion pictures and other audiovisual works ', value: 'motionPicture' },
  { label: 'Sound recordings', value: 'soundRecordings' },
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
            <Label>Type of Content Subject to Copyright</Label>
            <SelectInput
              value={value.typeOfContent}
              options={typeOfContent}
              onChange={v => this.onChange('typeOfContent', v)}
            />
          </InputGroup>

          {
            (dynamicFieldData.genre || [{}]).map(t => (
              <InputGroup>
                <Label>Specific Genre of Work</Label>
                <ReadOnlyInput value={t.genreTerm ? t.genreTerm.value : ''} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.form || [{}]).map(t => (
              <InputGroup>
                <Label>Form</Label>
                <ReadOnlyInput value={t.formTerm ? t.formTerm.value : ''} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.name || [{}]).map((n, i) => (
              <Card className="my-3">
                <Card.Header>{`Creator ${i + 1}`}</Card.Header>
                <Card.Body>
                  <InputGroup>
                    <Label>Name</Label>
                    <ReadOnlyInput value={n.nameTerm ? n.nameTerm.value : ''} />
                  </InputGroup>

                  <InputGroup>
                    <Label>Role(s)</Label>
                    <ReadOnlyInput value={n.nameRole ? n.nameRole.map(r => r.nameRoleTerm.value).join(', ') : ''} />
                  </InputGroup>

                  <InputGroup>
                    <Label>Date of Birth</Label>
                    <ReadOnlyInput value="" />
                  </InputGroup>

                  <InputGroup>
                    <Label>Date of Death</Label>
                    <ReadOnlyInput value="" />
                  </InputGroup>
                </Card.Body>
              </Card>
            ))
          }

          {
            (dynamicFieldData.title || [{}]).map(t => (
              <InputGroup>
                <Label>Title</Label>
                <ReadOnlyInput value={t.titleSortPortion} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.alternativeTitle || [{}]).map(t => (
              <InputGroup>
                <Label>Alternate Title</Label>
                <ReadOnlyInput value={t.alternativeTitleValue} />
              </InputGroup>
            ))
          }

          <InputGroup>
            <Label>Country of Origin</Label>
            <ControlledVocabularySelect
              vocabulary="geonames"
              value={value.countryOfOrigin}
              onChange={v => this.onChange('countryOfOrigin', v)}
            />
          </InputGroup>

          {
            (dynamicFieldData.publisher || [{}]).map(t => (
              <InputGroup>
                <Label>Publisher Name</Label>
                <ReadOnlyInput value={t.publisherValue} />
              </InputGroup>
            ))
          }

          {
            (dynamicFieldData.dateCreated || [{}]).map((d, i) => (
              <Card className="my-3">
                <Card.Header>{`Date of Creation ${i + 1}`}</Card.Header>
                <Card.Body>
                  <InputGroup>
                    <Label>Start Date</Label>
                    <ReadOnlyInput value={d.dateCreatedStartValue} />
                  </InputGroup>

                  <InputGroup>
                    <Label>End Date</Label>
                    <ReadOnlyInput value={d.dateCreatedEndValue} />
                  </InputGroup>

                  <InputGroup>
                    <Label>Type</Label>
                    <ReadOnlyInput value={d.dateCreatedType} />
                  </InputGroup>

                  <InputGroup>
                    <Label>Key Date</Label>
                    <ReadOnlyInput value={d.dateCreatedKeyDate} />
                  </InputGroup>
                </Card.Body>
              </Card>
            ))
          }

          {
            (dynamicFieldData.dateCreatedTextual || [{}]).map(t => (
              <InputGroup>
                <Label>Descriptive Date</Label>
                <ReadOnlyInput value={t.dateCreatedTextualValue} />
              </InputGroup>
            ))
          }

          <Collapse in={value.typeOfContent === 'motionPicture'}>
            <div>
              <InputGroup>
                <Label>Film distributed to public?</Label>
                <YesNoSelect
                  value={value.filmDistributedToPublic}
                  onChange={v => this.onChange('filmDistributedToPublic', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Film distributed commercially?</Label>
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
