import { WebuiPage } from './app.po';

describe('webui App', () => {
  let page: WebuiPage;

  beforeEach(() => {
    page = new WebuiPage();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!!');
  });
});
