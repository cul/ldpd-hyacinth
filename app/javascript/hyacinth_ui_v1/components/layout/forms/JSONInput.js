import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import 'brace';
import 'brace/mode/json';
import 'brace/theme/textmate';

class JSONInput extends React.PureComponent {
  render() {
    return (
      <AceEditor
        mode="json"
        theme="textmate"
        width="inherit"
        editorProps={{ $blockScrolling: true }}
        tabSize={2}
        {...this.props}
      />
    );
  }
}

JSONInput.propTypes = {
  name: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default JSONInput;
