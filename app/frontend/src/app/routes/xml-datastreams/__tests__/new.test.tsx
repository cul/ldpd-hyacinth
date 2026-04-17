import { describe, it, expect, vi, beforeAll, afterAll, type Mock, beforeEach } from 'vitest';
import {
  buildXmlDatastream,
  mockApiV2,
  renderApp,
  screen,
  userEvent,
} from '@/testing/test-utils';
import XmlDatastreamsNewRoute from '@/app/routes/xml-datastreams/new';

// Mock Monaco Editor since it doesn't work in jsdom
vi.mock('@monaco-editor/react', () => ({
  Editor: ({ value, onChange, onValidate, ...props }: any) => (
    <textarea
      data-testid="json-editor"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    />
  ),
}));

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('XML Datastreams New Route', () => {
  beforeEach(async () => {
    await renderApp(<XmlDatastreamsNewRoute />, { url: '/xml-datastreams/new' });
  });

  it('should render an empty xml datastream creation form', async () => {
    expect(screen.getByLabelText(/string key/i)).toHaveValue('');
    expect(screen.getByLabelText(/display label/i)).toHaveValue('');
    expect(screen.getByTestId('json-editor')).toHaveValue('{}');
  });

  it('should keep the String Key field enabled in creation mode', async () => {
    const stringKeyInput = screen.getByLabelText(/string key/i);
    expect(stringKeyInput).toBeEnabled();
  });

  it('should show success notification after filling out and submitting the form', async () => {
    const newXmlDatastream = buildXmlDatastream({
      stringKey: 'descMetadata',
      displayLabel: 'Descriptive Metadata',
      xmlTranslation: '{"render_if": {"present": ["restriction_on_access"]}}',
    });

    mockApiV2('post', '/xml_datastreams', { xmlDatastream: newXmlDatastream }, 201);

    await userEvent.type(screen.getByLabelText(/string key/i), 'descMetadata');
    await userEvent.type(screen.getByLabelText(/display label/i), 'Descriptive Metadata');

    await userEvent.click(screen.getByRole('button', { name: 'Create a New XML Datastream' }));

    expect(
      await screen.findByText(/was successfully created/i),
    ).toBeInTheDocument();
  });
});
