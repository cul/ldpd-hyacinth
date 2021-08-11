import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { snakeCase, words, last } from 'lodash';
import { Link } from 'react-router-dom';
import { useMutation } from '@apollo/react-hooks';

import UpArrowButton from '../buttons/UpArrowButton';
import DownArrowButton from '../buttons/DownArrowButton';
import { updateDynamicFieldGroupMutation } from '../../../graphql/dynamicFieldGroups';
import { updateDynamicFieldMutation } from '../../../graphql/dynamicFields';
import GraphQLErrors from '../GraphQLErrors';

function DynamicFieldsAndGroupsTable(props) {
  const { rows, onChange, ...rest } = props;

  const [updateDynamicFieldGroup, { error: updateGroupError }] = useMutation(
    updateDynamicFieldGroupMutation,
  );

  const [updateDynamicField, { error: updateFieldError }] = useMutation(
    updateDynamicFieldMutation,
  );

  const updateSortOrder = (type, id, sortOrder) => {
    const variables = { input: { id, sortOrder } };
    if (type === 'DynamicField') {
      updateDynamicField({ variables }).then(() => onChange());
    } else if (type === 'DynamicFieldGroup') {
      updateDynamicFieldGroup({ variables }).then(() => onChange());
    }
  };

  if (!Array.isArray(rows) || !rows.length) {
    return (<p>Child elements have not been defined.</p>);
  }

  return (
    <>
      <GraphQLErrors errors={updateGroupError || updateFieldError} />
      <Table hover borderless responsive {...rest}>
        <tbody>
          {
            rows.map((fieldOrGroup, index) => {
              const sortUp = (index === 0) ? null : Math.max(0, rows[index - 1].sortOrder - 1);
              const sortDown = (index === rows.length - 1) ? null : rows[index + 1].sortOrder + 1;

              const { displayLabel, id, type } = fieldOrGroup;

              return (
                <tr key={`${type}_${id}`}>
                  <td className="text-center"><span className="badge bg-primary" style={{ fontSize: '80%' }}>{last(words(type))}</span></td>
                  <td className="text-center">
                    <Link to={`/${snakeCase(type)}s/${id}/edit`}>
                      {displayLabel}
                    </Link>
                  </td>
                  <td className="text-center">
                    <UpArrowButton
                      variant="outline-secondary"
                      onClick={() => updateSortOrder(type, id, sortUp)}
                      disabled={sortUp === null}
                    />
                    <DownArrowButton
                      variant="outline-secondary"
                      onClick={() => updateSortOrder(type, id, sortDown)}
                      disabled={sortDown === null}
                    />
                  </td>
                </tr>
              );
            })
          }
        </tbody>
      </Table>
    </>
  );
}

DynamicFieldsAndGroupsTable.defaultProps = {
  rows: [],
};

DynamicFieldsAndGroupsTable.propTypes = {
  onChange: PropTypes.func.isRequired,
  rows: PropTypes.arrayOf(
    PropTypes.shape({
      displayLabel: PropTypes.string.isRequired,
      id: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
      sortOrder: PropTypes.number.isRequired,
    }),
  ),
};

export default DynamicFieldsAndGroupsTable;
