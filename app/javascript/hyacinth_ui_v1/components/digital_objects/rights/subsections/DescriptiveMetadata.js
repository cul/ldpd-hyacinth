import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';

import ReadOnlyInputGroup from '../form_inputs/ReadOnlyInputGroup';
import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import SelectInputGroup from '../form_inputs/SelectInputGroup';

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
  render() {
    const { value, dynamicFieldData, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Descriptive Metadata
          </Card.Title>

          <SelectInputGroup
            label="Type of Content Subject to Copyright"
            value={value.typeOfContent}
            options={typeOfContent}
            inputName="typeOfContent"
            onChange={onChange}
          />

          {
            dynamicFieldData.genre.map(t => (
              <ReadOnlyInputGroup label="Specific Genre of Work" value={t.genreTerm.value} />
            ))
          }

          {
            dynamicFieldData.form.map(t => (
              <ReadOnlyInputGroup label="Form" value={t.formTerm.value} />
            ))
          }

          {
            dynamicFieldData.name.filter(n => n.nameRole.map(r => r.nameRoleTerm.value).includes('Creator')).map((n, i) => (
              <Card className="my-3">
                <Card.Header className="p-2">{`Creator ${i + 1}`}</Card.Header>
                <Card.Body>
                  <ReadOnlyInputGroup label="Name" value={n.nameTerm.value} />
                  <ReadOnlyInputGroup label="Role(s)" value={n.nameRole.map(r => r.nameRoleTerm.value).join(', ')} />
                  <ReadOnlyInputGroup label="Date of Birth" value="" />
                  <ReadOnlyInputGroup label="Date of Death" value="" />
                </Card.Body>
              </Card>
            ))
          }

          {
            dynamicFieldData.title.map(t => (
              <ReadOnlyInputGroup label="Title" value={t.titleSortPortion} />
            ))
          }

          {
            dynamicFieldData.alternativeTitle.map(t => (
              <ReadOnlyInputGroup label="Alternate Title" value={t.alternativeTitleValue} />
            ))
          }

          {
            dynamicFieldData.publisher.map(t => (
              <ReadOnlyInputGroup label="Publisher Name" value={t.publisherValue} />
            ))
          }

          {
            dynamicFieldData.dateCreated.map((d, i) => (
              <Card className="my-3">
                <Card.Header className="p-2">{`Date of Creation ${i + 1}`}</Card.Header>
                <Card.Body>
                  <ReadOnlyInputGroup label="Start Date" value={d.dateCreatedStartValue} />
                  <ReadOnlyInputGroup label="End Date" value={d.dateCreatedEndValue} />
                  <ReadOnlyInputGroup label="Type" value={d.dateCreatedType} />
                  <ReadOnlyInputGroup label="Key Date" value={d.dateCreatedKeyDate} />
                </Card.Body>
              </Card>
            ))
          }

          {
            dynamicFieldData.dateCreatedTextual.map(t => (
              <ReadOnlyInputGroup label="Descriptive Date" value={t.dateCreatedTextualValue} />
            ))
          }

          <Collapse in={value.typeOfContent === 'motionPicture'}>
            <div>
              <BooleanInputGroup
                label="Film distributed to public?"
                inputName="filmDistributedToPublic"
                value={value.filmDistributedToPublic}
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Film distributed commercially?"
                inputName="filmDistributedCommercially"
                value={value.filmDistributedCommercially}
                onChange={onChange}
              />
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
