import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import { Col } from 'react-bootstrap';
import 'brace';
import 'brace/mode/json';
import 'brace/theme/textmate';

class JSONInput extends React.PureComponent {
  render() {
    const {
      inputName, onChange, value, height, placeholder, ...rest
    } = this.props;

    return (
      <Col sm={10} className="py-2" {...rest}>
        <AceEditor
          mode="json"
          theme="textmate"
          width="inherit"
          editorProps={{ $blockScrolling: true }}
          tabSize={2}
          onChange={onChange}
          value={value}
          name={inputName}
          height={height}
          placeholder={placeholder}
        />
      </Col>
    );
  }
}

JSONInput.propTypes = {
  inputName: PropTypes.string,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default JSONInput;
