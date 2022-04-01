import { initEmojiMock } from 'helpers/emoji';
import Emoji from '~/content_editor/extensions/emoji';
import { createTestEditor, createDocBuilder } from '../test_utils';

describe('content_editor/extensions/emoji', () => {
  let tiptapEditor;
  let doc;
  let p;
  let emoji;
  let eq;

  beforeEach(async () => {
    await initEmojiMock();
  });

  beforeEach(() => {
    tiptapEditor = createTestEditor({ extensions: [Emoji] });
    ({
      builders: { doc, p, emoji },
      eq,
    } = createDocBuilder({
      tiptapEditor,
      names: {
        loading: { nodeType: Emoji.name },
      },
    }));
  });

  describe('when typing a valid emoji input rule', () => {
    it('inserts an emoji node', () => {
      const { view } = tiptapEditor;
      const { selection } = view.state;
      const expectedDoc = doc(
        p(
          ' ',
          emoji({ moji: '❤', name: 'heart', title: 'heavy black heart', unicodeVersion: '1.1' }),
        ),
      );
      // Triggers the event handler that input rules listen to
      view.someProp('handleTextInput', (f) => f(view, selection.from, selection.to, ':heart:'));

      expect(eq(tiptapEditor.state.doc, expectedDoc)).toBe(true);
    });
  });

  describe('when typing a invalid emoji input rule', () => {
    it('does not insert an emoji node', () => {
      const { view } = tiptapEditor;
      const { selection } = view.state;
      const invalidEmoji = ':invalid:';
      const expectedDoc = doc(p());
      // Triggers the event handler that input rules listen to
      view.someProp('handleTextInput', (f) => f(view, selection.from, selection.to, invalidEmoji));
      expect(eq(tiptapEditor.state.doc, expectedDoc)).toBe(true);
    });
  });
});
