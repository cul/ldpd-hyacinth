import React from 'react';
import produce from 'immer';
import { camelCase } from 'lodash';
import { Card } from 'react-bootstrap';

import digitalObjectInterface from '../digitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';
import { dynamicFieldCategories } from '../../../util/hyacinth_api';
import InputGroup from '../../ui/forms/InputGroup';
import Label from '../../ui/forms/Label';
import PlainText from '../../ui/forms/inputs/PlainText';

class MetadataShow extends React.PureComponent {
  state = {
    dynamicFields: [],
  }

  componentDidMount() {
    dynamicFieldCategories.all()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFields = res.data.dynamicFieldCategories;
        }));
      });
  }

  renderField(dynamicField, data) {
    const { displayLabel, fieldType } = dynamicField;

    return (
      <InputGroup>
        <Label align="right">{displayLabel}</Label>
        <PlainText value={fieldType === 'controlled_term' ? data.prefLabel : data } />
      </InputGroup>
    );
  }

  renderGroup(dynamicGroup, data) {
    const {
      stringKey, displayLabel, isRepeatable, children,
    } = dynamicGroup;

    return (
      data.map((d, i) => (
        <Card key={`${stringKey}_${i + 1}`}>
          <Card.Header>
            {displayLabel}
            {isRepeatable ? ` ${i + 1}` : ''}
          </Card.Header>
          <Card.Body>
            {
              children.map((c) => {
                if (d[camelCase(c.stringKey)]) {
                  if (c.type === 'DynamicFieldGroup') {
                    return this.renderGroup(c, d[camelCase(c.stringKey)]);
                  } if (c.type === 'DynamicField') {
                    return this.renderField(c, d[camelCase(c.stringKey)]);
                  }
                }
                return '';
              })
            }
          </Card.Body>
        </Card>
      ))
    );
  }

  renderCategory(dynamicCategory, data) {
    const { displayLabel, children } = dynamicCategory;

    const filteredChildren = children.filter(c => data[camelCase(c.stringKey)]);

    return (
      filteredChildren.length
        ? (
          <div key={displayLabel}>
            <h4 className="text-orange">{displayLabel}</h4>
            {
              filteredChildren.map(c => this.renderGroup(c, data[camelCase(c.stringKey)]))
            }
          </div>
        )
        : ''
    );
  }

  render() {
    const { match: { params: { id } }, data: { dynamicFieldData } } = this.props;
    const { dynamicFields } = this.state;

    return (
      <>
        <TabHeading>
          Metadata
          <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${id}/metadata/edit`}
          />
        </TabHeading>

        { dynamicFields.map(category => this.renderCategory(category, dynamicFieldData)) }
      </>
    );
  }
}

export default digitalObjectInterface(MetadataShow);
