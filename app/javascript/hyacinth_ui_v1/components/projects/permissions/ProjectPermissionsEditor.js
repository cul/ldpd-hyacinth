import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import GraphQLErrors from '../../ui/GraphQLErrors';

import { getProjectPermissionsQuery } from '../../../graphql/projects';

function ProjectPermissionsEditor(props) {
  const { loading, error, data } = useQuery(getProjectPermissionsQuery, { variables: { stringKey: props.project.stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <div>
      Editor
      { JSON.stringify(data) }
    </div>
  );
}

ProjectPermissionsEditor.propTypes = {
  readonly: PropTypes.bool,
};

ProjectPermissionsEditor.defaultProps = {
  readonly: false,
};

export default ProjectPermissionsEditor;
