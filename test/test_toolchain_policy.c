/*
 * ADR-0224, the Toolchain Tenet: TCC by right, gcc by evidence.
 *
 * The rule is that Cix's own code is always TCC -- no bar, no
 * exception -- and third-party packages are TCC by default and gcc
 * when TCC is difficult. ADR-0226 amended ADR-0224 here: the original
 * four-part bar and its required tracking issue NO LONGER APPLY to
 * third-party packages, because the owner's instruction is that moving
 * a package this project neither owns nor wrote should be the natural
 * change rather than a battle. What is still required is CPDL's
 * `toolchain "gcc" { reason "..." }`, for auditability rather than
 * permission -- a reason may be as ordinary as "the language has no
 * TCC front end". CBS itself refuses `compiler "gcc"` without one
 * (CPDL-E3004), so each recipe is gated at publish; this test is the
 * aggregate the per-recipe check cannot give.
 *
 * The rule is not the interesting part -- an informal version of it
 * already existed, as prose in CLAUDE.md, and did not stop gcc
 * reaching 21 recipes without anyone counting.
 *
 * This is the part that makes it real: a NUMBER that changes visibly.
 * Adding a gcc package means editing the list below, in a diff,
 * deliberately. Since ADR-0226 this is a VISIBILITY device rather than
 * a debt ceiling -- the set is expected to GROW, and that is fine; what
 * must not happen is it growing without anyone seeing it -- the same device test_apigen uses to keep the REST
 * surface honest. A rule nobody can count is a rule that has already
 * been broken, and this project has the evidence: 34 of 139 installed
 * packages had drifted behind their recipes because nothing counted
 * them either (#217).
 *
 * Deliberately checks only what is mechanically true: whether a
 * recipe declares or invokes gcc. Whether the reason recorded beside
 * it is a GOOD reason is review, and a gate pretending to judge that
 * would be the kind that passes while the thing it names is wrong.
 *
 * Comments are excluded from the scan on purpose. Several recipes
 * discuss gcc at length -- why they do not use it, or what it did
 * differently -- and counting prose would make the number meaningless
 * within a week.
 */

#include <dirent.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Every package whose latest revision builds with gcc. Each one
 * declares it with a reason, which CBS requires; this list is what
 * makes the SET visible, so adding a name here is the deliberate edit.
 *
 * Re-derived on 2026-10-25 from the corpus at that day's main, after
 * this file was found never to have compiled in this repository: it
 * used a recipe-suffix macro from cix's headers without including any
 * of them, and the macro had since been renamed there (cix#628). The 32 names it carried then had
 * become 41 -- the meson-built set (glib, pixman, libslirp, qemu; the
 * meson fact is in cix's CLAUDE.md), edk2's (acpica, edk2-basetools,
 * ovmf, probe-edk2-build), and others -- and three shell-recipe
 * probes had left the corpus with the shell form.
 */
static const char *const g_gcc_recipes[] = {
	"acpica", "bind-utils", "binutils", "binutils-dev", "bird", "btop", "btrfs-progs",
	"cmake", "edk2-basetools", "efivar", "elfutils", "fastfetch", "gcc", "gitea", "glauth",
	"glib", "glibc", "gnu-efi", "go", "go-bootstrap", "grub", "kernel", "keyutils", "kmod",
	"libblkid", "libffi", "libslirp", "libxcrypt", "linux-headers", "ninja", "node",
	"openssl", "ovmf", "perl", "pixman", "probe-edk2-build", "probe-go-race", "python",
	"qemu", "util-linux",
	/*
	 * quickjs: a JS engine's Makefile adds -fwrapv unconditionally --
	 * its signed-overflow behaviour is load-bearing for JavaScript's
	 * integer semantics -- and TCC does not implement it. Build-only,
	 * and its consumer is test_web_syntax, which is Cix's own code and
	 * therefore still TCC: the exception is the third-party library,
	 * not the gate that links it (#340).
	 */
	"quickjs",
};
#define GCC_RECIPE_COUNT ((int)(sizeof(g_gcc_recipes) / sizeof(g_gcc_recipes[0])))

static int g_failures;

static void fail(const char *fmt, ...)
{
	va_list ap;

	fputs("FAIL: ", stderr);
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fputc('\n', stderr);
	g_failures++;
}

static int known_gcc_recipe(const char *name)
{
	int i;

	for (i = 0; i < GCC_RECIPE_COUNT; i++) {
		if (strcmp(g_gcc_recipes[i], name) == 0)
			return 1;
	}
	return 0;
}

/* Highest version directory, the same "latest revision" rule the
 * daemon's own resolution uses: digit runs numerically, the rest
 * lexically. */
static int version_newer(const char *a, const char *b)
{
	while (*a != '\0' && *b != '\0') {
		if (*a >= '0' && *a <= '9' && *b >= '0' && *b <= '9') {
			long na = 0, nb = 0;

			while (*a >= '0' && *a <= '9')
				na = na * 10 + (*a++ - '0');
			while (*b >= '0' && *b <= '9')
				nb = nb * 10 + (*b++ - '0');
			if (na != nb)
				return na > nb;
			continue;
		}
		if (*a != *b)
			return (unsigned char)*a > (unsigned char)*b;
		a++;
		b++;
	}
	return *b == '\0' && *a != '\0';
}

/*
 * Does this recipe DECLARE gcc?
 *
 * `toolchain "gcc"` is the authoritative answer and is checked first,
 * because the scan below can only see a compiler a recipe names out
 * loud -- and a recipe need not name one at all. `cmake` runs
 * `./bootstrap`, `fastfetch` runs `cmake`; both build with g++ or gcc,
 * both declare it with a measured reason, and neither writes a
 * compiler in any phase. They were counted as TCC recipes and broke
 * the total while both recipes were entirely correct.
 *
 * So the two signals answer different questions and both are kept. A
 * declaration is what a recipe says; the scan is what it does. Their
 * union is the set of gcc recipes, and the scan's real job is the case
 * the declaration cannot cover -- a recipe that reaches for gcc
 * WITHOUT declaring it, which is the undetected move ADR-0224 exists
 * to make impossible.
 *
 * The node is indented, so leading whitespace is skipped. The walk in
 * main() reads only .cbs files: a recipe is CPDL and nothing else
 * (cix ADR-0329), and a format this textual scan did not recognise
 * would be a silent zero rather than an error.
 */
static int recipe_declares_gcc(const char *path)
{
	FILE *f = fopen(path, "r");
	char line[4096];
	int declares = 0;

	if (f == NULL)
		return 0;
	while (fgets(line, sizeof(line), f) != NULL) {
		const char *q = line;

		while (*q == ' ' || *q == '\t')
			q++;
		if (strncmp(q, "toolchain \"gcc\"", 15) == 0) {
			declares = 1;
			break;
		}
	}
	fclose(f);
	return declares;
}

/*
 * Does this recipe actually invoke the gcc toolchain?
 *
 * Scans the whole file, skipping comment lines: a CPDL recipe's phases
 * ARE the document, and its metadata carries no compiler invocation to
 * confuse the scan.
 *
 * g++ counts. It is the same toolchain wearing its C++ driver, and a
 * recipe that builds with it is exactly as much a gcc recipe as one
 * calling gcc -- which is the whole thing this count exists to keep
 * visible. Added when btop, the first C++ package here, declared
 * gcc and went undetected because it invokes CXX
 * rather than CC: an undetected gcc recipe is worse than a miscounted
 * one, since it means a package can move to gcc without the diff
 * anybody reviews ever showing it.
 */
static int recipe_uses_gcc(const char *path)
{
	FILE *f = fopen(path, "r");
	char line[4096];
	int uses = 0;

	if (f == NULL)
		return 0;
	while (fgets(line, sizeof(line), f) != NULL) {
		const char *p = line;

		while (*p == ' ' || *p == '\t')
			p++;
		if (*p == '#')
			continue;
		if (strstr(p, "/usr/bin/gcc") != NULL || strstr(p, "CC=gcc") != NULL ||
		    strstr(p, "--cc=gcc") != NULL || strstr(p, "-Dcc=gcc") != NULL ||
		    strstr(p, "/usr/bin/g++") != NULL || strstr(p, "CXX=g++") != NULL) {
			uses = 1;
			break;
		}
	}
	fclose(f);
	return uses;
}

/*
 * cix#505: splits "<name>@<version>.<ext>". Mirrors the daemon's own
 * recipe_file_split() in daemon/src/pkg.c -- this test links no daemon
 * code, which is what lets it run anywhere, so the rule is restated
 * rather than shared. Both split at the FIRST '@' and take the
 * extension from the LAST dot, so a dotted version
 * (xorriso@1.5.8.pl02-8.cbs) parses.
 */
static int recipe_split(const char *fname, char *name, size_t name_size,
                        char *version, size_t version_size, const char **ext)
{
	const char *at, *dot;
	size_t nlen, vlen;

	if (fname == NULL || fname[0] == '.')
		return -1;
	at = strchr(fname, '@');
	if (at == NULL || at == fname)
		return -1;
	dot = strrchr(at, '.');
	if (dot == NULL || dot == at + 1)
		return -1;
	nlen = (size_t)(at - fname);
	vlen = (size_t)(dot - (at + 1));
	if (nlen == 0 || nlen >= name_size || vlen == 0 || vlen >= version_size)
		return -1;
	memcpy(name, fname, nlen);
	name[nlen] = '\0';
	memcpy(version, at + 1, vlen);
	version[vlen] = '\0';
	if (ext != NULL)
		*ext = dot + 1;
	return 0;
}

int main(void)
{
	DIR *d = opendir("recipes/package");
	struct dirent *ent;
	int found = 0;

	if (d == NULL) {
		fprintf(stderr, "FAIL: cannot open recipes/package -- run from the repository root\n");
		return 1;
	}

	/*
	 * cix#505: the corpus is FLAT -- one file per recipe, named
	 * "<name>@<version>.<ext>" -- so "the newest revision of each
	 * package" is found by asking, for each file, whether a higher
	 * version of the same name exists. No inner directory to walk.
	 */
	while ((ent = readdir(d)) != NULL) {
		char name[256], version[256], path[2048];
		struct dirent *e2;
		DIR *d2;
		int outranked = 0;
		const char *ext;

		if (recipe_split(ent->d_name, name, sizeof(name), version, sizeof(version),
		                 &ext) != 0)
			continue;
		if (strcmp(ext, "cbs") != 0)
			continue;

		d2 = opendir("recipes/package");
		if (d2 == NULL)
			continue;
		while ((e2 = readdir(d2)) != NULL) {
			char n2[256], v2[256];
			const char *x2;

			if (recipe_split(e2->d_name, n2, sizeof(n2), v2, sizeof(v2), &x2) != 0)
				continue;
			if (strcmp(x2, "cbs") != 0)
				continue;
			if (strcmp(n2, name) != 0)
				continue;
			if (version_newer(v2, version)) {
				outranked = 1;
				break;
			}
		}
		closedir(d2);
		if (outranked)
			continue;

		snprintf(path, sizeof(path), "recipes/package/%s", ent->d_name);
		if (!recipe_declares_gcc(path) && !recipe_uses_gcc(path))
			continue;
		found++;
		if (!known_gcc_recipe(name)) {
			fail("%s@%s builds with gcc and is not in this test's list.\n"
			     "       ADR-0226: gcc is an ordinary choice for a third-party package,\n"
			     "       so this is not a refusal -- it is a request to make the change\n"
			     "       visible. Give it a toolchain \"gcc\" { reason } naming what was\n"
			     "       measured, then add it to g_gcc_recipes[] here.\n"
			     "       That edit is the point: the set may grow, but never unnoticed.",
			     name, version);
		}
	}
	closedir(d);

	if (found != GCC_RECIPE_COUNT)
		fail("found %d recipes building with gcc, this test expects %d.\n"
		     "       If one was RETIRED back to TCC -- which is the direction this list\n"
		     "       is supposed to move -- remove it from g_gcc_recipes[] and lower the\n"
		     "       count with it.",
		     found, GCC_RECIPE_COUNT);

	if (g_failures > 0) {
		fprintf(stderr, "TOOLCHAIN POLICY: FAIL (%d)\n", g_failures);
		return 1;
	}
	printf("TOOLCHAIN POLICY: PASS (%d gcc exceptions, all declared)\n", found);
	return 0;
}
