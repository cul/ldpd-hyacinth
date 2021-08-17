import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import { Col } from 'react-bootstrap';
import 'ace-builds/src-noconflict/mode-json';
import 'ace-builds/src-noconflict/theme-textmate';
import 'ace-builds/webpack-resolver';

function JSONInput(props) {
  const {
    inputName, onChange, value, height, placeholder, ...rest
  } = props;

  return (
    <Col className="py-2" {...rest}>
      <AceEditor
        mode="json"
        theme="textmate"
        width="inherit"
        editorProps={{ $blockScrolling: true }}
        tabSize={2}
        onChange={v => onChange(v)} // only send the first param to the callback function
        value={value == null ? '' : value}
        name={inputName}
        height={height}
        placeholder={placeholder}
      />
    </Col>
  );
}

JSONInput.defaultProps = {
  inputName: null,
  height: undefined,
  placeholder: undefined,
};

JSONInput.propTypes = {
  inputName: PropTypes.string,
  height: PropTypes.string,
  placeholder: PropTypes.string,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default JSONInput;
