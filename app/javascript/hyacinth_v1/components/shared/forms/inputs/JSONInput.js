import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import { Col } from 'react-bootstrap';
import 'brace';
import 'brace/mode/json';
import 'brace/theme/textmate';

function JSONInput(props) {
  const {
    inputName, onChange, value, height, placeholder, ...rest
  } = props;

  return (
    <Col sm={10} className="py-2" {...rest}>
      <AceEditor
        mode="json"
        theme="textmate"
        width="inherit"
        editorProps={{ $blockScrolling: true }}
        tabSize={2}
        onChange={v => onChange(v)} // only send the first param to the callback function
        value={value}
        name={inputName}
        height={height}
        placeholder={placeholder}
      />
    </Col>
  );
}

JSONInput.defaultProps = {
  inputName: null,
  height: null,
  placeholder: null,
};

JSONInput.propTypes = {
  inputName: PropTypes.string,
  height: PropTypes.string,
  placeholder: PropTypes.string,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default JSONInput;
