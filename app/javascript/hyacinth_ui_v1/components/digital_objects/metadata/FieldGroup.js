import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';
import { camelCase } from 'lodash';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Field from './Field';
import FieldGroupArray from './FieldGroupArray';
import AddButton from '../../ui/buttons/AddButton';
import RemoveButton from '../../ui/buttons/RemoveButton';
import UpArrowButton from '../../ui/buttons/UpArrowButton';
import DownArrowButton from '../../ui/buttons/DownArrowButton';


class FieldGroup extends React.Component {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
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
                <span className="float-right"><AddButton onClick={addHandler} /></span>
                <span className="float-right"><UpArrowButton onClick={() => moveHandler('up')} /></span>
                <span className="float-right"><DownArrowButton onClick={() => moveHandler('down')} /></span>
                <span className="float-right"><RemoveButton onClick={removeHandler} /></span>
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
                      value={value[camelCase(c.stringKey)]}
                      defaultValue={defaultValue[camelCase(c.stringKey)][0]}
                      dynamicFieldGroup={c}
                      onChange={v => this.onChange(camelCase(c.stringKey), v)}
                    />
                  );
                case 'DynamicField':
                  return (
                    <Field
                      key={c.stringKey}
                      value={value[camelCase(c.stringKey)]}
                      dynamicField={c}
                      onChange={v => this.onChange(camelCase(c.stringKey), v)}
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
