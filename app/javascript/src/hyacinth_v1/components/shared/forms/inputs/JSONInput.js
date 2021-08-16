import React, { useImperativeHandle, useRef } from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import { Col } from 'react-bootstrap';
import 'ace-builds/src-noconflict/mode-json';
import 'ace-builds/src-noconflict/theme-textmate';
import 'ace-builds/webpack-resolver';

const JSONInput = React.forwardRef((props, ref) => {
  const {
    inputName, onChange, value, height, placeholder, valueHandle, ...rest
  } = props;
  const aceEditor = useRef(null);
  const valueHandler = {};
  valueHandler[valueHandle] = () => aceEditor.current.editor.getValue();
  useImperativeHandle(ref, () => (valueHandler));

  const editorOpts = {
    useWorker: 'false',
  };

  return (
    <Col className="py-2" {...rest}>
      <AceEditor
        mode="json"
        theme="textmate"
        width="inherit"
        editorProps={{ $blockScrolling: true }}
        tabSize={2}
        onChange={onChange}
        value={value == null ? '' : value}
        name={inputName}
        height={height}
        placeholder={placeholder}
        setOptions={editorOpts}
        ref={aceEditor}
      />
    </Col>
  );
});

JSONInput.defaultProps = {
  inputName: null,
  height: undefined,
  placeholder: undefined,
  onChange: () => {},
  valueHandle: 'jsonValue',
};

JSONInput.propTypes = {
  inputName: PropTypes.string,
  height: PropTypes.string,
  placeholder: PropTypes.string,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func,
  valueHandle: PropTypes.string,
};

export default JSONInput;
