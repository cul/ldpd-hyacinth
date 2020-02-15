import React, { useState } from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useParams, useHistory } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import CancelButton from '../../shared/forms/buttons/CancelButton';
import SubmitButton from '../../shared/forms/buttons/SubmitButton';
import { Can } from '../../../utils/abilityContext';
import ProjectInterface from '../ProjectInterface';
import { getProjectQuery, updateProjectMutation, deleteProjectMutation } from '../../../graphql/projects';
import GraphQLErrors from '../../shared/GraphQLErrors';

function CoreDataEdit() {
  const { stringKey } = useParams();
  const history = useHistory();

  const [displayLabel, setDisplayLabel] = useState('');
  const [isPrimary, setIsPrimary] = useState(false);
  const [hasAssetRights, setHasAssetRights] = useState(false);
  const [projectUrl, setProjectUrl] = useState('');

  // Retrieve data and set data
  const { loading, error, data } = useQuery(
    getProjectQuery,
    {
      variables: { stringKey },
      onCompleted: (projectData) => {
        const { project } = projectData;

        setDisplayLabel(project.displayLabel);
        setProjectUrl(project.projectUrl);
        setIsPrimary(project.isPrimary);
        setHasAssetRights(project.hasAssetRights);
      },
    },
  );

  const [updateProject, { error: updateError }] = useMutation(updateProjectMutation);
  const [deleteProject, { error: deleteError }] = useMutation(deleteProjectMutation);

  const onSubmitHandler = (e) => {
    e.preventDefault();

    const variables = {
      input: {
          stringKey: data.project.stringKey, displayLabel, projectUrl, hasAssetRights,
      },
    };

    updateProject({ variables }).then(() => history.push(`/projects/${stringKey}/core_data`));
  };

  const onDeleteHandler = (e) => {
    e.preventDefault();

    const variables = { input: { stringKey: data.project.stringKey } };

    deleteProject({ variables }).then(() => history.push('/projects/'));
  };

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Editing Core Data</TabHeading>

      <GraphQLErrors errors={updateError || deleteError} />

      <Form as={Col} onSubmit={onSubmitHandler}>
        <Form.Group as={Row}>
          <Form.Label column sm={2}>String Key</Form.Label>
          <Col sm={10}>
            <Form.Control plaintext readOnly value={data.project.stringKey} />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Display Label</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="displayLabel"
              value={displayLabel}
              onChange={e => setDisplayLabel(e.target.value)}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Project URL</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="projectUrl"
              value={projectUrl}
              onChange={e => setProjectUrl(e.target.value)}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Is Primary</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="checkbox"
              name="isPrimary"
              checked={isPrimary}
              disabled
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Has Asset Rights</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="checkbox"
              name="hasAssetRights"
              value={hasAssetRights}
              onChange={e => setHasAssetRights(isPrimary && e.target.checked)}
              disabled={!isPrimary}
              checked={isPrimary && hasAssetRights}
            />
          </Col>
        </Form.Group>

        <Form.Row>
          <Col sm="auto" className="mr-auto">
            <Can I="delete" a="Project">
              <Button variant="outline-danger" type="submit" onClick={onDeleteHandler}>Delete Project</Button>
            </Can>
          </Col>

          <Col sm="auto" className="ml-auto">
            <CancelButton to={`/projects/${stringKey}/core_data`} />
          </Col>

          <Col sm="auto">
            <SubmitButton formType="edit" onClick={onSubmitHandler} />
          </Col>
        </Form.Row>
      </Form>
    </ProjectInterface>
  );
}

export default CoreDataEdit;

//
//
// class CoreDataEdit extends React.Component {
//   state = {
//     project: {
//       stringKey: '',
//       displayLabel: '',
//       projectUrl: '',
//     },
//   }
//
//   onChangeHandler = (event) => {
//     const { target: { name, value } } = event;
//     this.setState(produce((draft) => { draft.project[name] = value; }));
//   }
//
//   onSubmitHandler = (event) => {
//     event.preventDefault();
//
//     const { project: { stringKey, displayLabel, projectUrl } } = this.state
//     const data = { project: { displayLabel, projectUrl }, };
//
//     hyacinthApi.patch(`/projects/${stringKey}`, data)
//       .then((res) => {
//         this.props.history.push(`/projects/${stringKey}/core_data`);
//       });
//   }
//
//   onDeleteHandler = (event) => {
//     event.preventDefault();
//
//     hyacinthApi.delete(`/projects/${this.props.match.params.stringKey}`)
//       .then((res) => {
//         this.props.history.push('/projects/');
//       });
//   }
//
//   componentDidMount = () => {
//     hyacinthApi.get(`/projects/${this.props.match.params.stringKey}`)
//       .then((res) => {
//         const { project } = res.data;
//
//         this.setState(produce((draft) => {
//           draft.project = project;
//         }));
//       });
//   }
//
//   render() {
//     const { project: { stringKey, displayLabel, projectUrl } } = this.state;
//     return (
//       <>
//         <TabHeading>Editing Core Data</TabHeading>
//
//         <Form as={Col} onSubmit={this.onSubmitHandler}>
//           <Form.Group as={Row}>
//             <Form.Label column sm={2}>String Key</Form.Label>
//             <Col sm={10}>
//               <Form.Control plaintext readOnly value={stringKey} />
//             </Col>
//           </Form.Group>
//
//           <Form.Group as={Row}>
//             <Form.Label column sm={2}>Display Label</Form.Label>
//             <Col sm={10}>
//               <Form.Control
//                 type="text"
//                 name="displayLabel"
//                 value={displayLabel}
//                 onChange={this.onChangeHandler}
//               />
//             </Col>
//           </Form.Group>
//
//           <Form.Group as={Row}>
//             <Form.Label column sm={2}>Project URL</Form.Label>
//             <Col sm={10}>
//               <Form.Control
//                 type="text"
//                 name="projectUrl"
//                 value={projectUrl}
//                 onChange={this.onChangeHandler}
//               />
//             </Col>
//           </Form.Group>
//
//           <Form.Row>
//             <Col sm="auto" className="mr-auto">
//               <Can I="delete" a="Project">
//                 <Button variant="outline-danger" type="submit" onClick={this.onDeleteHandler}>Delete Project</Button>
//               </Can>
//             </Col>
//
//             <Col sm="auto" className="ml-auto">
//               <CancelButton to={`/projects/${stringKey}/core_data`} />
//             </Col>
//
//             <Col sm="auto">
//               <SubmitButton formType="edit" onClick={this.onSubmitHandler} />
//             </Col>
//           </Form.Row>
//         </Form>
//       </>
//     );
//   }
// }

// export default withErrorHandler(CoreDataEdit, hyacinthApi);
