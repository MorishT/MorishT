(() => {
  const STORAGE_KEY = 'preferred-language';
  const DEFAULT_LANGUAGE = 'ja';
  const VALID_LANGUAGES = new Set(['ja', 'en']);

  const readSavedLanguage = () => {
    try {
      const savedLanguage = window.localStorage.getItem(STORAGE_KEY);
      return VALID_LANGUAGES.has(savedLanguage) ? savedLanguage : null;
    } catch (error) {
      return null;
    }
  };

  const writeSavedLanguage = (language) => {
    try {
      window.localStorage.setItem(STORAGE_KEY, language);
    } catch (error) {}
  };

  const updateDocumentTitle = (language) => {
    if (!document.body) {
      return;
    }

    const siteTitle =
      language === 'en'
        ? document.body.dataset.siteTitleEn || document.title
        : document.body.dataset.siteTitleJa || document.title;
    const pageTitle =
      language === 'en'
        ? document.body.dataset.pageTitleEn
        : document.body.dataset.pageTitleJa;
    const isHome = document.body.dataset.isHome === 'true';

    document.title = !isHome && pageTitle ? `${pageTitle} | ${siteTitle}` : siteTitle;
  };

  const readForcedLanguage = () => {
    if (document.body?.dataset.forcedLang) {
      return VALID_LANGUAGES.has(document.body.dataset.forcedLang) ? document.body.dataset.forcedLang : null;
    }

    const htmlLanguage = document.documentElement.dataset.siteLang;
    const htmlForced = document.documentElement.dataset.siteLangForced === 'true';
    return htmlForced && VALID_LANGUAGES.has(htmlLanguage) ? htmlLanguage : null;
  };

  const readLanguageUrl = (language) => {
    if (!document.body) {
      return null;
    }

    const attributeName = language === 'en' ? 'langUrlEn' : 'langUrlJa';
    const url = document.body.dataset[attributeName];
    return url && url.trim() !== '' ? url : null;
  };

  const applyLanguage = (language, persist) => {
    const nextLanguage = VALID_LANGUAGES.has(language) ? language : DEFAULT_LANGUAGE;
    const html = document.documentElement;

    html.dataset.siteLang = nextLanguage;
    html.setAttribute('lang', nextLanguage);

    document.querySelectorAll('[data-lang-switch]').forEach((button) => {
      const isActive = button.dataset.langSwitch === nextLanguage;
      button.classList.toggle('is-active', isActive);
      button.setAttribute('aria-pressed', String(isActive));
    });

    updateDocumentTitle(nextLanguage);

    if (persist) {
      writeSavedLanguage(nextLanguage);
    }
  };

  document.addEventListener('DOMContentLoaded', () => {
    const forcedLanguage = readForcedLanguage();
    const initialLanguage = forcedLanguage || readSavedLanguage() || document.documentElement.dataset.siteLang || DEFAULT_LANGUAGE;

    applyLanguage(initialLanguage, false);

    document.querySelectorAll('[data-lang-switch]').forEach((button) => {
      button.addEventListener('click', () => {
        const nextLanguage = button.dataset.langSwitch;
        writeSavedLanguage(nextLanguage);

        const targetUrl = readLanguageUrl(nextLanguage);
        if (targetUrl && targetUrl !== window.location.pathname) {
          window.location.assign(targetUrl);
          return;
        }

        applyLanguage(nextLanguage, false);
      });
    });
  });
})();
