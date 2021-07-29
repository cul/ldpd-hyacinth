import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Field from './Field';
import FieldGroupArray from './FieldGroupArray';
import AddButton from '../../shared/buttons/AddButton';
import RemoveButton from '../../shared/buttons/RemoveButton';
import UpArrowButton from '../../shared/buttons/UpArrowButton';
import DownArrowButton from '../../shared/buttons/DownArrowButton';


const FieldGroup = (props) => {
  const {
    index,
    addHandler,
    removeHandler,
    moveHandler,
    value,
    onChange,
    defaultValue,
    dynamicFieldGroup: { stringKey, displayLabel, children, isRepeatable }
  } = props;

  const onChangeWrapper = (fieldName, fieldVal) => {
    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    return onChange(nextValue);
  };

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
                    onChange={v => onChangeWrapper(c.stringKey, v)}
                  />
                );
              case 'DynamicField':
                return (
                  <Field
                    key={c.stringKey}
                    value={value[c.stringKey]}
                    dynamicField={c}
                    onChange={v => onChangeWrapper(c.stringKey, v)}
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
};

export default FieldGroup;
