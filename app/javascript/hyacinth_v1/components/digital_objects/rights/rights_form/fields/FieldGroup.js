import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import AddButton from '@hyacinth_v1/components/shared/buttons/AddButton';
import RemoveButton from '@hyacinth_v1/components/shared/buttons/RemoveButton';
import UpArrowButton from '@hyacinth_v1/components/shared/buttons/UpArrowButton';
import DownArrowButton from '@hyacinth_v1/components/shared/buttons/DownArrowButton';
import Field from './Field';
import FieldGroupArray from './FieldGroupArray';

/* This is a copy of the class for the metadata form, these can be merged later when the use the same strategy to update state */

class FieldGroup extends React.Component {
  onChange(fieldName, fieldVal) {
    const { onChange } = this.props;

    onChange(produce((draft) => {
      draft[fieldName] = fieldVal;
    }));
  }

  onArrayChange(index, updates) {
    const { onChange } = this.props;

    onChange((obj) => {
      const updated = updates(obj[index]);
      return produce(obj, (draft) => {
        draft[index] = updated;
      });
    });
  }

  render() {
    const {
      index,
      addHandler,
      removeHandler,
      moveHandler,
      value,
      defaultValue,
      dynamicFieldGroup: { stringKey, displayLabel, children, isRepeatable }
    } = this.props;


    return (
      <Card className="my-2" key={stringKey}>
        <Card.Header>
          {isRepeatable ? `${displayLabel} ${index + 1}` : displayLabel}
          {
            isRepeatable && (
              <>
                <span className="float-right"><AddButton tabIndex="-1" className="field-group-header-button" onClick={addHandler} /></span>
                <span className="float-right"><UpArrowButton tabIndex="-1" className="field-group-header-button" onClick={() => moveHandler('up')} /></span>
                <span className="float-right"><DownArrowButton tabIndex="-1" className="field-group-header-button" onClick={() => moveHandler('down')} /></span>
                <span className="float-right"><RemoveButton tabIndex="-1" className="field-group-header-button" onClick={removeHandler} /></span>
              </>
            )
          }

        </Card.Header>
        <Card.Body>
          {
            children.map((c) => {
              switch (c.type) {
                case 'DynamicFieldGroup':
                  return (
                    <FieldGroupArray
                      key={c.stringKey}
                      value={value[c.stringKey]}
                      defaultValue={defaultValue[c.stringKey][0]}
                      dynamicFieldGroup={c}
                      onChange={v => this.onArrayChange(c.stringKey, v)}
                    />
                  );
                case 'DynamicField':
                  return (
                    <Field
                      key={c.stringKey}
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
