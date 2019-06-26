import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Field from './Field';
import FieldGroupArray from './FieldGroupArray';

class FieldGroup extends React.Component {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value, dynamicFieldGroup: { stringKey, displayLabel, children } } = this.props;

    return (
      <Card className="my-2">
        <Card.Header>{displayLabel}</Card.Header>
        <Card.Body>
          {
            children.map((c) => {
              switch (c.type) {
                case 'DynamicFieldGroup':
                  return (
                    <FieldGroupArray
                      value={value[c.stringKey]}
                      dynamicFieldGroup={c}
                      onChange={v => this.onChange(c.stringKey, v)}
                    />
                  );
                case 'DynamicField':
                  return (
                    <Field
                      value={value[c.stringKey]}
                      dynamicField={c}
                      onChange={v => this.onChange(c.stringKey, v)}
                    />
                  );
                default:
                  return '';
              }
            })
          }
        </Card.Body>
      </Card>
    );
  }
}

export default FieldGroup;
