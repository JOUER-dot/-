import { describe, it, expect, vi, beforeEach } from 'vitest'
import { downloadCSV } from './export'

describe('downloadCSV', () => {
  let appendChildSpy: ReturnType<typeof vi.spyOn>
  let removeChildSpy: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    appendChildSpy = vi.spyOn(document.body, 'appendChild').mockImplementation((el) => el)
    removeChildSpy = vi.spyOn(document.body, 'removeChild').mockImplementation((el) => el as Node)
  })

  it('should create an anchor element and trigger download', () => {
    const clickSpy = vi.fn()
    vi.spyOn(document, 'createElement').mockReturnValue({
      href: '',
      download: '',
      click: clickSpy
    } as unknown as HTMLAnchorElement)

    downloadCSV('http://example.com/data.csv', 'export.csv')

    expect(document.createElement).toHaveBeenCalledWith('a')
    expect(appendChildSpy).toHaveBeenCalled()
    expect(clickSpy).toHaveBeenCalled()
    expect(removeChildSpy).toHaveBeenCalled()
  })

  it('should set correct href and download attributes', () => {
    let anchor: any = null
    vi.spyOn(document, 'createElement').mockImplementation((tag) => {
      anchor = { href: '', download: '', click: vi.fn() }
      return anchor as unknown as HTMLAnchorElement
    })

    downloadCSV('/api/export/data', 'report.csv')

    expect(anchor!.href).toBe('/api/export/data')
    expect(anchor!.download).toBe('report.csv')
  })
})
